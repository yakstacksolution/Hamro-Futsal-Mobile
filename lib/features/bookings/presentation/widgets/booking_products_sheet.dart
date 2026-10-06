import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_details_widgets.dart';
import 'package:hamro_futsal/features/products/data/model/product_models.dart';

bool bookingSupportsProducts(BookingModel booking) {
  return booking.status == BookingStatus.confirmed;
}

bool bookingCanComplete(BookingModel booking) {
  return booking.status == BookingStatus.confirmed;
}

enum BookingPaymentType {
  cash,
  online;

  String get apiValue => name;

  String get label => this == BookingPaymentType.cash ? 'Cash' : 'Online';

  IconData get icon => this == BookingPaymentType.cash
      ? Icons.payments_rounded
      : Icons.account_balance_wallet_rounded;
}

class BookingPaymentLine {
  const BookingPaymentLine({required this.type, required this.amount});

  final BookingPaymentType type;
  final double amount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'payment_type': type.apiValue,
    'value': amount == amount.roundToDouble() ? amount.round() : amount,
  };
}

class BookingCompleteResult {
  const BookingCompleteResult({
    required this.payments,
    required this.discount,
    required this.amountPaid,
    required this.isPartial,
  });

  final List<BookingPaymentLine> payments;
  final double discount;
  final double amountPaid;
  final bool isPartial;

  BookingPaymentType get paymentType =>
      payments
          .where((BookingPaymentLine l) => l.amount > 0)
          .firstOrNull
          ?.type ??
      payments.firstOrNull?.type ??
      BookingPaymentType.cash;
}

class BookingCompletionResponse {
  const BookingCompletionResponse({required this.success, this.booking});

  final bool success;
  final BookingModel? booking;

  BookingModel completedFrom(BookingModel original) {
    final BookingModel? returned = booking;
    return (returned != null && returned.id == original.id
            ? returned
            : original)
        .copyWith(status: BookingStatus.completed);
  }
}

final Set<int> _bookingsBeingCompleted = <int>{};

final Map<int, Future<BookingCompletionResponse>> _pendingCompletions =
    <int, Future<BookingCompletionResponse>>{};

Future<void> runBookingCompletionOnce(
  int bookingId,
  Future<void> Function() flow,
) async {
  if (!_bookingsBeingCompleted.add(bookingId)) return;
  try {
    await flow();
  } finally {
    _bookingsBeingCompleted.remove(bookingId);
  }
}

@visibleForTesting
Future<BookingCompletionResponse> Function(
  int bookingId, {
  BookingCompleteResult? result,
  List<Map<String, dynamic>>? extraItems,
})?
debugSendCompleteBooking;

Future<BookingCompletionResponse> completeBooking(
  int bookingId, {
  BookingCompleteResult? result,
  List<Map<String, dynamic>>? extraItems,
}) {
  final Future<BookingCompletionResponse>? pending =
      _pendingCompletions[bookingId];
  if (pending != null) return pending;

  final Future<BookingCompletionResponse> request =
      (debugSendCompleteBooking ?? _sendCompleteBooking)(
        bookingId,
        result: result,
        extraItems: extraItems,
      ).whenComplete(() {
        // A block, not `=> remove(...)`: `remove` returns this very future,
        // and `whenComplete` waits on a future its callback returns — the
        // request would wait on itself and never complete.
        _pendingCompletions.remove(bookingId);
      });
  _pendingCompletions[bookingId] = request;
  return request;
}

Future<BookingCompletionResponse> _sendCompleteBooking(
  int bookingId, {
  BookingCompleteResult? result,
  List<Map<String, dynamic>>? extraItems,
}) async {
  final response = await Client.instance().getAuthManager().completeBooking(
    bookingId: bookingId,
    // `confirm` is required by the API; completing always confirms.
    confirm: true,
    // Each type with what it paid — cash, online, or both.
    payments: result == null
        ? null
        : <Map<String, dynamic>>[
            for (final BookingPaymentLine line in result.payments)
              if (line.amount > 0) line.toJson(),
          ],
    discount: result?.discount ?? 0,
    // Only sent for a partial settlement — a full payment omits it.
    partialAmount: (result != null && result.isPartial)
        ? result.amountPaid
        : null,
    extraItems: extraItems,
  );
  if (!response.isSuccess()) {
    return const BookingCompletionResponse(success: false);
  }
  try {
    return BookingCompletionResponse(
      success: true,
      booking: BookingModel.fromResponse(response.getValue()),
    );
  } catch (_) {
    return const BookingCompletionResponse(success: true);
  }
}

class BookingCollectDueResult {
  const BookingCollectDueResult({
    required this.amount,
    required this.paymentMethod,
    required this.paymentNote,
  });

  final double amount;
  final BookingPaymentType paymentMethod;
  final String paymentNote;
}

Future<bool> collectBookingDue(
  int bookingId,
  BookingCollectDueResult result,
) async {
  final response = await Client.instance().getAuthManager().collectBookingDue(
    bookingId: bookingId,
    data: <String, dynamic>{
      'amount': result.amount,
      'payment_method': result.paymentMethod.apiValue,
      'payment_note': result.paymentNote.trim(),
    },
  );
  return response.isSuccess();
}

Future<BookingCollectDueResult?> showCollectBookingDueSheet(
  BuildContext context,
  BookingModel booking,
) {
  return showAppBottomSheet<BookingCollectDueResult>(
    context: context,
    wrapWithCustomSheet: false,
    builder: (_) => _CollectBookingDueSheet(booking: booking),
  );
}

Future<BookingCompleteResult?> showBookingCompleteSheet(
  BuildContext context,
  BookingModel booking,
) {
  return showAppBottomSheet<BookingCompleteResult>(
    context: context,
    wrapWithCustomSheet: false,
    builder: (_) => _CompleteBookingSheet(booking: booking),
  );
}

Future<bool?> openBookingProductsSheet(
  BuildContext context,
  BookingModel booking,
) {
  return showAppBottomSheet<bool>(
    context: context,
    wrapWithCustomSheet: false,
    builder: (_) => _ProductsCartSheet(booking: booking),
  );
}

// ─── Data access (thin wrapper over the shared API client) ────────────────────

class _BookingProductsService {
  const _BookingProductsService();

  Future<List<ProductModel>> fetchVenueProducts(int venueId) async {
    final response = await Client.instance().getAuthManager().getVenueProducts(
      venueId: venueId,
    );
    if (response.isError()) {
      throw Exception('Could not load products for this venue.');
    }
    return _parseProducts(response.getValue())
        .where((ProductModel p) => p.id > 0 && p.name.isNotEmpty && p.isActive)
        .toList(growable: false);
  }

  Future<void> submit(int bookingId, Map<ProductModel, int> cart) async {
    final List<Map<String, dynamic>> items = cart.entries
        .where((MapEntry<ProductModel, int> e) => e.value > 0)
        .map(
          (MapEntry<ProductModel, int> e) => <String, dynamic>{
            'product_id': e.key.id,
            'quantity': e.value,
          },
        )
        .toList(growable: false);
    final response = await Client.instance()
        .getAuthManager()
        .addBookingProducts(
          bookingId: bookingId,
          data: <String, dynamic>{'extra_items': items},
        );
    if (response.isError()) {
      throw Exception('Could not add products to this booking.');
    }
  }

  List<ProductModel> _parseProducts(dynamic payload) {
    return _findList(payload, 0)
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<dynamic> _findList(dynamic node, int depth) {
    if (node is List) return node;
    if (node is Map && depth < 4) {
      for (final String key in const <String>[
        'data',
        'products',
        'items',
        'results',
      ]) {
        final dynamic child = node[key];
        if (child == null) continue;
        final List<dynamic> found = _findList(child, depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return const <dynamic>[];
  }
}

// ─── Products section shown on the booking details page ──────────────────────

class BookingProductsSection extends StatelessWidget {
  const BookingProductsSection({
    super.key,
    required this.booking,
    this.onChanged,
    this.canAdd = true,
  });

  final BookingModel booking;

  final VoidCallback? onChanged;

  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final List<BookingExtraItemModel> items = booking.extraItems;
    if (items.isEmpty) {
      return canAdd
          ? _AddProductsTile(booking: booking, onChanged: onChanged)
          : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ExtraItemsCard(items: items, total: booking.extraItemsTotal),
        if (canAdd) ...<Widget>[
          const SizedBox(height: AppDimens.paddingX10),
          _AddProductsTile(booking: booking, onChanged: onChanged),
        ],
      ],
    );
  }
}

class _ExtraItemsCard extends StatelessWidget {
  const _ExtraItemsCard({required this.items, required this.total});

  final List<BookingExtraItemModel> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return BookingDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: AppDimens.paddingX12),
            _ExtraItemRow(item: items[i]),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX12),
            child: Divider(height: 1, color: LightColor.dividerColor),
          ),
          BookingAmountRow(
            label: 'Products subtotal',
            value: _formatMoney(total),
            labelWeight: FontWeight.w600,
            valueWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

class _ExtraItemRow extends StatelessWidget {
  const _ExtraItemRow({required this.item});

  final BookingExtraItemModel item;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name.trim().isEmpty ? 'Product' : item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX2),
              Text(
                item.unitPrice > 0
                    ? '${item.quantity} × ${_formatMoney(item.unitPrice)}'
                    : 'Qty ${item.quantity}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Text(
          _formatMoney(item.totalAmount),
          style: textTheme.bodyTextMedium?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AddProductsTile extends StatelessWidget {
  const _AddProductsTile({required this.booking, this.onChanged});

  final BookingModel booking;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final bool hasItems = booking.extraItems.isNotEmpty;
    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: () async {
          final bool? added = await openBookingProductsSheet(context, booking);
          if (added == true) onChanged?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX16,
            vertical: AppDimens.paddingX14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.add_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX18,
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Text(
                  hasItems ? 'Add more products' : 'Add products',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: LightColor.iconGrey,
                size: AppDimens.sizeX18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingActionChip extends StatelessWidget {
  const BookingActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = LightColor.secondaryColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: AppDimens.sizeX14, color: color),
              const SizedBox(width: AppDimens.paddingX4),
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── The cart sheet ───────────────────────────────────────────────────────────

class _ProductsCartSheet extends StatefulWidget {
  const _ProductsCartSheet({required this.booking});

  final BookingModel booking;

  @override
  State<_ProductsCartSheet> createState() => _ProductsCartSheetState();
}

class _ProductsCartSheetState extends State<_ProductsCartSheet> {
  static const _BookingProductsService _service = _BookingProductsService();

  late Future<List<ProductModel>> _future;
  final Map<int, int> _quantities = <int, int>{};
  List<ProductModel> _products = <ProductModel>[];
  bool _submitting = false;

  int get _venueId => widget.booking.venueId ?? 0;

  @override
  void initState() {
    super.initState();
    // Pre-fill the cart with products already attached to this booking so the
    // sheet reflects the current extra_items and their counts.
    for (final BookingExtraItemModel item in widget.booking.extraItems) {
      if (item.productId > 0 && item.quantity > 0) {
        _quantities[item.productId] = item.quantity;
      }
    }
    _future = _load();
  }

  Future<List<ProductModel>> _load() async {
    if (_venueId <= 0) {
      throw Exception('This booking is missing venue information.');
    }
    final List<ProductModel> venueProducts = await _service.fetchVenueProducts(
      _venueId,
    );
    // Merge in products already attached to this booking (extra_items) so they
    // always show with their counts even if deactivated or missing from the
    // active venue list. Existing entries keep the venue product details.
    final List<ProductModel> merged = <ProductModel>[...venueProducts];
    final Set<int> ids = merged.map((ProductModel p) => p.id).toSet();
    for (final BookingExtraItemModel item in widget.booking.extraItems) {
      if (item.productId <= 0 || ids.contains(item.productId)) continue;
      merged.add(
        ProductModel(
          id: item.productId,
          venueId: _venueId,
          name: item.name.isEmpty ? 'Product #${item.productId}' : item.name,
          price: item.unitPrice,
          isActive: true,
        ),
      );
      ids.add(item.productId);
    }
    // Already-added products (pre-filled quantity) float to the top.
    merged.sort((ProductModel a, ProductModel b) {
      final bool sa = (_quantities[a.id] ?? 0) > 0;
      final bool sb = (_quantities[b.id] ?? 0) > 0;
      if (sa == sb) return 0;
      return sa ? -1 : 1;
    });
    _products = merged;
    return merged;
  }

  double _priceFor(int productId) {
    for (final ProductModel product in _products) {
      if (product.id == productId) return product.price;
    }
    for (final BookingExtraItemModel item in widget.booking.extraItems) {
      if (item.productId == productId) return item.unitPrice;
    }
    return 0;
  }

  double get _total {
    double sum = 0;
    _quantities.forEach((int productId, int quantity) {
      sum += _priceFor(productId) * quantity;
    });
    return sum;
  }

  int get _itemCount =>
      _quantities.values.fold<int>(0, (int sum, int qty) => sum + qty);

  void _setQuantity(ProductModel product, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _quantities.remove(product.id);
      } else {
        _quantities[product.id] = quantity;
      }
    });
  }

  Future<void> _submit() async {
    if (_itemCount == 0 || _submitting) return;
    setState(() => _submitting = true);
    try {
      final Map<ProductModel, int> cart = <ProductModel, int>{
        for (final ProductModel p in _products)
          if ((_quantities[p.id] ?? 0) > 0) p: _quantities[p.id]!,
      };
      await _service.submit(widget.booking.id, cart);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppUtils().showSnackBar(
        context,
        MsgType.success,
        'Products added to the booking.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Could not add products. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    return CustomBottomSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(context),
            const SizedBox(height: AppDimens.paddingX12),
            Flexible(
              child: FutureBuilder<List<ProductModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _CartLoading();
                  }
                  if (snapshot.hasError) {
                    return _CartMessage(
                      icon: Icons.wifi_off_rounded,
                      color: LightColor.redColor,
                      title: 'Could not load products',
                      subtitle: 'Check your connection and try again.',
                      onRetry: () => setState(() => _future = _load()),
                    );
                  }
                  final List<ProductModel> products =
                      snapshot.data ?? const <ProductModel>[];
                  if (products.isEmpty) {
                    return const _CartMessage(
                      icon: Icons.inventory_2_outlined,
                      color: LightColor.secondaryColor,
                      title: 'No products available',
                      subtitle:
                          'This venue has no active products to sell yet.',
                    );
                  }
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                      top: AppDimens.paddingX4,
                      bottom: AppDimens.paddingX8,
                    ),
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimens.paddingX10),
                    itemBuilder: (_, int i) {
                      final ProductModel product = products[i];
                      return _CartProductTile(
                        product: product,
                        quantity: _quantities[product.id] ?? 0,
                        calculatedAmount:
                            product.price * (_quantities[product.id] ?? 0),
                        onChanged: (int qty) => _setQuantity(product, qty),
                      );
                    },
                  );
                },
              ),
            ),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add products',
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX2),
              Text(
                'Sell water, drinks & add-ons for this booking.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        if (_itemCount > 0) ...<Widget>[
          const SizedBox(width: AppDimens.paddingX8),
          // The same chip the cards use, so the count reads as a state of the
          // sheet rather than as a second button.
          DataCardChip(
            label: '$_itemCount item${_itemCount == 1 ? '' : 's'}',
            color: LightColor.secondaryColor,
          ),
        ],
      ],
    );
  }

  Widget _footer(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX12),
      child: Column(
        children: <Widget>[
          Divider(height: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX12),
          Row(
            children: <Widget>[
              Text(
                'Total',
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatMoney(_total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
                  // Same tabular digits as the cards, so the total does not
                  // jitter as quantities change.
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          CustomButton(
            text: _itemCount == 0
                ? 'Add products'
                : 'Add to booking ($_itemCount)',
            icon: Icons.check_rounded,
            isLoading: _submitting,
            onPressed: _itemCount == 0 ? null : _submit,
            minHeight: AppDimens.sizeX48,
          ),
        ],
      ),
    );
  }
}

// ─── Complete-booking sheet ───────────────────────────────────────────────────

String _formatMoney(double amount) => Money.npr(amount);

class _CollectBookingDueSheet extends StatefulWidget {
  const _CollectBookingDueSheet({required this.booking});

  final BookingModel booking;

  @override
  State<_CollectBookingDueSheet> createState() =>
      _CollectBookingDueSheetState();
}

class _CollectBookingDueSheetState extends State<_CollectBookingDueSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final TextEditingController _noteController = TextEditingController(
    text: 'Collected remaining due amount in person',
  );
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();
  BookingPaymentType _paymentMethod = BookingPaymentType.cash;

  double get _due => widget.booking.amountDueForCollection;
  double? get _enteredAmount =>
      double.tryParse(_amountController.text.trim().replaceAll(',', ''));
  bool get _canSubmit {
    final double? amount = _enteredAmount;
    return amount != null && amount > 0 && amount <= _due;
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _due.toStringAsFixed(_due % 1 == 0 ? 0 : 2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final double? amount = double.tryParse(
      value?.trim().replaceAll(',', '') ?? '',
    );
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    if (amount > _due) return 'Amount cannot exceed ${_formatMoney(_due)}';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      BookingCollectDueResult(
        amount: double.parse(_amountController.text.trim().replaceAll(',', '')),
        paymentMethod: _paymentMethod,
        paymentNote: _noteController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final double sheetHeight =
        (media.size.height * 0.55 - media.viewInsets.bottom).clamp(
          media.size.height * 0.32,
          media.size.height * 0.55,
        );
    return CustomBottomSheet(
      padding: EdgeInsets.only(
        top: AppDimens.paddingX12,
        bottom: media.viewInsets.bottom,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX18,
                AppDimens.paddingX8,
                AppDimens.paddingX18,
                AppDimens.paddingX16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Collect due amount',
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX4),
                  Text(
                    '${_formatMoney(_due)} remains due for this completed booking.',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX18,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomTextField(
                        key: const Key('collect-due-amount-field'),
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        labelText: 'Amount',
                        hintText: 'Enter collected amount',
                        icon: Icons.payments_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        ensureVisibleOnFocus: true,
                        onSubmitted: (_) => _noteFocusNode.requestFocus(),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateAmount,
                      ),
                      const SizedBox(height: AppDimens.paddingX16),
                      _SectionLabel('Payment method'),
                      const SizedBox(height: AppDimens.paddingX8),
                      _SegmentedChoice(
                        labels: <String>[
                          for (final BookingPaymentType type
                              in BookingPaymentType.values)
                            type.label,
                        ],
                        selectedIndex: BookingPaymentType.values.indexOf(
                          _paymentMethod,
                        ),
                        onSelected: (int index) => setState(
                          () =>
                              _paymentMethod = BookingPaymentType.values[index],
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingX16),
                      CustomTextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        labelText: 'Payment note',
                        hintText: 'How was the due amount collected?',
                        isRequired: false,
                        minLines: 2,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        ensureVisibleOnFocus: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(1000),
                        ],
                      ),
                      const SizedBox(height: AppDimens.paddingX16),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimens.paddingX18,
                AppDimens.paddingX12,
                AppDimens.paddingX18,
                AppDimens.paddingX12 + media.padding.bottom,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: LightColor.dividerColor)),
              ),
              child: CustomButton(
                key: const Key('submit-collect-due-button'),
                text: 'Collect ${_formatMoney(_enteredAmount ?? 0)}',
                icon: Icons.payments_rounded,
                onPressed: _canSubmit ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteBookingSheet extends StatefulWidget {
  const _CompleteBookingSheet({required this.booking});

  final BookingModel booking;

  @override
  State<_CompleteBookingSheet> createState() => _CompleteBookingSheetState();
}

class _CompleteBookingSheetState extends State<_CompleteBookingSheet> {
  final TextEditingController _discountController = TextEditingController();

  final List<_CompletePaymentField> _payments = <_CompletePaymentField>[
    _CompletePaymentField(BookingPaymentType.cash),
  ];

  bool _amountTouched = false;

  BookingModel get _booking => widget.booking;

  double get _totalToCollect => _booking.amountDueForCompletion;

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '')) ?? 0;

  double _bound(double value, double max) {
    if (value.isNaN || value < 0) return 0;
    return value > max ? max : value;
  }

  double get _discount => _bound(_parse(_discountController), _totalToCollect);

  double get _netPayable =>
      _bound(_totalToCollect - _discount, double.infinity);

  double get _received => _payments.fold<double>(
    0,
    (double sum, _CompletePaymentField p) => sum + _parse(p.amount),
  );

  double get _amountPaid => _bound(_received, _netPayable);

  double get _remaining => _bound(_netPayable - _amountPaid, double.infinity);

  bool get _overpaid => _received > _netPayable + 0.5;

  bool get _emptySplitLine =>
      _payments.length > 1 &&
      _payments.any((_CompletePaymentField p) => _parse(p.amount) <= 0);

  bool get _canComplete =>
      !_overpaid && !_emptySplitLine && (_netPayable <= 0 || _received > 0);

  static BookingPaymentType _other(BookingPaymentType type) =>
      type == BookingPaymentType.cash
      ? BookingPaymentType.online
      : BookingPaymentType.cash;

  static String _amountText(double amount) => amount <= 0
      ? ''
      : (amount == amount.roundToDouble()
            ? amount.round().toString()
            : amount.toStringAsFixed(2));

  @override
  void initState() {
    super.initState();
    _payments.first.amount.text = _amountText(_netPayable);
  }

  @override
  void dispose() {
    _discountController.dispose();
    for (final _CompletePaymentField p in _payments) {
      p.dispose();
    }
    super.dispose();
  }

  void _onDiscountChanged() {
    setState(() {
      if (!_amountTouched && _payments.length == 1) {
        _payments.first.amount.text = _amountText(_netPayable);
      }
    });
  }

  void _addSplit() {
    if (_payments.length > 1) return;
    final _CompletePaymentField line = _CompletePaymentField(
      _other(_payments.first.type),
    );
    line.amount.text = _amountText(_netPayable - _received);
    setState(() {
      _amountTouched = true;
      _payments.add(line);
    });
  }

  void _removeLine(int index) {
    if (_payments.length <= 1) return;
    setState(() => _payments.removeAt(index).dispose());
  }

  void _fillShare(double share) {
    final _CompletePaymentField last = _payments.last;
    final double others = _received - _parse(last.amount);
    setState(() {
      _amountTouched = true;
      last.amount.text = _amountText(_netPayable * share - others);
    });
  }

  void _onComplete() {
    Navigator.of(context).pop(
      BookingCompleteResult(
        payments: <BookingPaymentLine>[
          for (final _CompletePaymentField p in _payments)
            BookingPaymentLine(type: p.type, amount: _parse(p.amount)),
        ],
        discount: _discount,
        amountPaid: _amountPaid,
        isPartial: _remaining > 0,
      ),
    );
  }

  String get _typesLabel {
    final List<String> used = <String>[
      for (final _CompletePaymentField p in _payments)
        if (_parse(p.amount) > 0) p.type.label,
    ];
    return used.isEmpty ? _payments.first.type.label : used.join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final MediaQueryData media = MediaQuery.of(context);
    // Fixed 80% of the screen so the sheet opens at the same size every time,
    // shrinking only for the keyboard.
    final double height = (media.size.height * 0.8 - media.viewInsets.bottom)
        .clamp(media.size.height * 0.4, media.size.height * 0.8);
    return CustomBottomSheet(
      // Padding is handled per-slot so the footer can span the full width; the
      // keyboard inset lifts the whole sheet instead of covering the actions.
      padding: EdgeInsets.only(
        top: AppDimens.paddingX12,
        bottom: media.viewInsets.bottom,
      ),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX18,
                AppDimens.paddingX10,
                AppDimens.paddingX18,
                AppDimens.paddingX16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Complete booking',
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX4),
                  Text(
                    'Review the payment and record how it was collected. '
                    'This can\'t be undone.',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX18,
                  0,
                  AppDimens.paddingX18,
                  AppDimens.paddingX18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ReceiptCard(
                      booking: _booking,
                      totalToCollect: _totalToCollect,
                    ),
                    const SizedBox(height: AppDimens.paddingX18),

                    _SectionLabel('Discount'),
                    const SizedBox(height: AppDimens.paddingX8),
                    CustomTextField(
                      controller: _discountController,
                      labelText: 'Discount amount',
                      hintText: 'e.g. 100',
                      icon: Icons.local_offer_rounded,
                      isRequired: false,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => _onDiscountChanged(),
                    ),
                    const SizedBox(height: AppDimens.paddingX18),

                    _SectionLabel('Payment'),
                    const SizedBox(height: AppDimens.paddingX8),
                    for (int i = 0; i < _payments.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: AppDimens.paddingX10),
                      _CompletePaymentRow(
                        key: ValueKey<_CompletePaymentField>(_payments[i]),
                        line: _payments[i],
                        // Split: each line is its type's, fixed — one cash,
                        // one online.
                        locked: _payments.length > 1,
                        label: _payments.length == 1
                            ? 'Amount received now (NPR)'
                            : '${_payments[i].type.label} received (NPR)',
                        onTypeChanged: (BookingPaymentType t) =>
                            setState(() => _payments[i].type = t),
                        onAmountChanged: () => setState(() {
                          _amountTouched = true;
                        }),
                        onRemove: _payments.length > 1
                            ? () => _removeLine(i)
                            : null,
                      ),
                    ],
                    const SizedBox(height: AppDimens.paddingX8),
                    Row(
                      children: <Widget>[
                        if (_netPayable > 0)
                          for (final (String label, double share)
                              in const <(String, double)>[
                                ('25%', 0.25),
                                ('50%', 0.5),
                                ('Full', 1),
                              ]) ...<Widget>[
                            Expanded(
                              child: CustomButton(
                                text: label,
                                isOutlined: true,
                                foregroundColor: LightColor.brandTextColor,
                                borderColor: LightColor.dividerColor,
                                minWidth: 0,
                                minHeight: AppDimens.sizeX36,
                                verticalPadding: 0,
                                fontSize: AppDimens.fontBodyTextSmall,
                                onPressed: () => _fillShare(share),
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingX8),
                          ]
                        else
                          const Spacer(),
                        // Part in cash, the rest online: the other type's
                        // line. Gone once both are there.
                        if (_payments.length == 1)
                          TextButton.icon(
                            key: const Key('complete-add-split'),
                            onPressed: _addSplit,
                            style: TextButton.styleFrom(
                              foregroundColor: LightColor.brandTextColor,
                              minimumSize: const Size(0, AppDimens.sizeX36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.paddingX8,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              'Add ${_other(_payments.first.type).label.toLowerCase()}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_overpaid || _emptySplitLine) ...<Widget>[
                      const SizedBox(height: AppDimens.paddingX8),
                      Text(
                        _overpaid
                            ? 'More than the amount due '
                                  '(${_formatMoney(_netPayable)}).'
                            : 'Enter an amount for each payment, or remove '
                                  'it.',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.redColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimens.paddingX14),
                    _SettlementSummary(
                      discount: _discount,
                      netPayable: _netPayable,
                      collectingNow: _amountPaid,
                      remaining: _remaining,
                    ),
                    if (_amountPaid > 0) ...<Widget>[
                      const SizedBox(height: AppDimens.paddingX8),
                      Text(
                        '${_remaining > 0 ? 'Partly paid' : 'Paid in full'}'
                        ' · $_typesLabel',
                        key: const Key('complete-payment-status'),
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Pinned footer — same treatment as the booking details action bar.
            _CompleteSheetFooter(
              onCancel: () => Navigator.of(context).pop(),
              onComplete: _canComplete ? _onComplete : null,
              amount: _amountPaid,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletePaymentField {
  _CompletePaymentField(this.type);

  BookingPaymentType type;
  final TextEditingController amount = TextEditingController();

  void dispose() => amount.dispose();
}

class _CompletePaymentRow extends StatelessWidget {
  const _CompletePaymentRow({
    super.key,
    required this.line,
    required this.label,
    required this.locked,
    required this.onTypeChanged,
    required this.onAmountChanged,
    this.onRemove,
  });

  final _CompletePaymentField line;
  final String label;

  final bool locked;
  final ValueChanged<BookingPaymentType> onTypeChanged;
  final VoidCallback onAmountChanged;

  final VoidCallback? onRemove;

  static const double _height = 48;
  static const double _typeWidth = 112;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        locked ? _typeChip() : _typeToggle(),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: CustomTextField(
            controller: line.amount,
            labelText: label,
            hintText: '0',
            isRequired: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[
              // Digits and at most one decimal point, so it always parses.
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (_) => onAmountChanged(),
          ),
        ),
        if (onRemove != null)
          SizedBox(
            height: _height,
            child: IconButton(
              tooltip: 'Remove this payment',
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _typeToggle() {
    Widget option(BookingPaymentType type) {
      final bool selected = type == line.type;
      final Color fg = selected
          ? LightColor.onBrandSurface
          : LightColor.secondaryTextColor;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: 'Paid by ${type.label}',
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTypeChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? LightColor.secondaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(type.icon, size: 15, color: fg),
                      const SizedBox(height: 1),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: _typeWidth,
      height: _height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          option(BookingPaymentType.cash),
          const SizedBox(width: 3),
          option(BookingPaymentType.online),
        ],
      ),
    );
  }

  Widget _typeChip() {
    return Semantics(
      label: 'Paid by ${line.type.label}',
      child: ExcludeSemantics(
        child: Container(
          width: _typeWidth,
          height: _height,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(line.type.icon, size: 16, color: LightColor.brandTextColor),
              const SizedBox(width: 6),
              Text(
                line.type.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LightColor.brandTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteSheetFooter extends StatelessWidget {
  const _CompleteSheetFooter({
    required this.onCancel,
    required this.onComplete,
    required this.amount,
  });

  final VoidCallback onCancel;
  final VoidCallback? onComplete;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppDimens.paddingX18,
        AppDimens.paddingX12,
        AppDimens.paddingX18,
        AppDimens.paddingX12 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Collecting now',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                Text(
                  _formatMoney(amount),
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          SizedBox(
            width: 92,
            child: CustomButton(
              text: 'Cancel',
              isOutlined: true,
              foregroundColor: LightColor.secondaryTextColor,
              borderColor: LightColor.dividerColor,
              minHeight: AppDimens.sizeX42,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX10),
          SizedBox(
            width: 122,
            child: CustomButton(
              text: 'Complete',
              backgroundColor: LightColor.secondaryColor,
              minHeight: AppDimens.sizeX42,
              onPressed: onComplete,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.secondaryTextColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SegmentedChoice extends StatelessWidget {
  const _SegmentedChoice({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingX10,
                  ),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? LightColor.cardColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    border: Border.all(
                      color: i == selectedIndex
                          ? LightColor.secondaryColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: i == selectedIndex
                          ? LightColor.secondaryColor
                          : LightColor.secondaryTextColor,
                      fontWeight: i == selectedIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettlementSummary extends StatelessWidget {
  const _SettlementSummary({
    required this.discount,
    required this.netPayable,
    required this.collectingNow,
    required this.remaining,
  });

  final double discount;
  final double netPayable;
  final double collectingNow;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          if (discount > 0)
            _SettlementRow(label: 'Discount', amount: -discount),
          _SettlementRow(label: 'Payable after discount', amount: netPayable),
          _SettlementRow(
            label: 'Collecting now',
            amount: collectingNow,
            emphasize: true,
          ),
          _SettlementRow(
            label: 'Remaining due',
            amount: remaining,
            highlightRemaining: remaining > 0,
          ),
        ],
      ),
    );
  }
}

class _SettlementRow extends StatelessWidget {
  const _SettlementRow({
    required this.label,
    required this.amount,
    this.emphasize = false,
    this.highlightRemaining = false,
  });

  final String label;
  final double amount;
  final bool emphasize;
  final bool highlightRemaining;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final Color valueColor = highlightRemaining
        ? LightColor.warningColor
        : LightColor.primaryTextColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatMoney(amount),
            style: textTheme.bodyTextSmall?.copyWith(
              color: valueColor,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.booking, required this.totalToCollect});

  final BookingModel booking;
  final double totalToCollect;

  @override
  Widget build(BuildContext context) {
    final List<BookingExtraItemModel> items = booking.extraItems;
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _ReceiptSectionLabel('Booking payment'),
          const SizedBox(height: AppDimens.paddingX10),
          _ReceiptRow(
            label: 'Subtotal',
            amount: booking.subtotal > 0
                ? booking.subtotal
                : booking.bookingTotal,
          ),
          if (booking.discountAmount > 0)
            _ReceiptRow(label: 'Discount', amount: -booking.discountAmount),
          if (booking.taxAmount > 0)
            _ReceiptRow(label: 'Tax', amount: booking.taxAmount),
          _ReceiptRow(
            label: 'Booking total',
            amount: booking.bookingTotal,
            emphasize: true,
          ),
          if (booking.effectivePaidAmount > 0)
            _ReceiptRow(
              label: 'Already paid',
              amount: booking.effectivePaidAmount,
            ),
          _ReceiptRow(
            label: 'Balance due',
            amount: booking.remainingBookingBalance,
            emphasize: true,
          ),

          const SizedBox(height: AppDimens.paddingX14),
          const _ReceiptDivider(),
          const SizedBox(height: AppDimens.paddingX14),

          Row(
            children: <Widget>[
              const Expanded(child: _ReceiptSectionLabel('Extra items')),
              if (items.isNotEmpty)
                Text(
                  '${booking.extraItemsCount} item'
                  '${booking.extraItemsCount == 1 ? '' : 's'}',
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(color: LightColor.secondaryTextColor),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          if (items.isEmpty)
            Text(
              'No extra items on this booking.',
              style: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
            )
          else ...<Widget>[
            for (final BookingExtraItemModel item in items)
              _ReceiptRow(
                label: item.name.isEmpty
                    ? 'Product #${item.productId}'
                    : item.name,
                subLabel: '${item.quantity} × ${_formatMoney(item.unitPrice)}',
                amount: item.totalAmount,
              ),
            _ReceiptRow(
              label: 'Extra items total',
              amount: booking.extraItemsTotal,
              emphasize: true,
            ),
          ],

          const SizedBox(height: AppDimens.paddingX14),
          const _ReceiptDivider(),
          const SizedBox(height: AppDimens.paddingX14),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Total to collect',
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                _formatMoney(totalToCollect),
                style: FutsalTheme.getTextTheme(context).bodyTextLarge
                    ?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptSectionLabel extends StatelessWidget {
  const _ReceiptSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.secondaryTextColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _ReceiptDivider extends StatelessWidget {
  const _ReceiptDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: LightColor.dividerColor);
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.amount,
    this.subLabel,
    this.emphasize = false,
  });

  final String label;
  final double amount;
  final String? subLabel;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final Color labelColor = emphasize
        ? LightColor.primaryTextColor
        : LightColor.secondaryTextColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: emphasize ? LightColor.primaryTextColor : labelColor,
                    fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (subLabel != null) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX2),
                  Text(
                    subLabel!,
                    style: textTheme.bodyMiniSubTitle?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Text(
            _formatMoney(amount),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartProductTile extends StatelessWidget {
  const _CartProductTile({
    required this.product,
    required this.quantity,
    required this.calculatedAmount,
    required this.onChanged,
  });

  final ProductModel product;
  final int quantity;
  final double calculatedAmount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final bool selected = quantity > 0;
    return DataCard(
      selected: selected,
      animate: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.formattedPrice} ${StringConstants.each}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                // The line total appears only once there is one, so an
                // untouched card stays two quiet lines.
                if (selected) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    _formatMoney(calculatedAmount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          _QuantityStepper(quantity: quantity, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    if (quantity == 0) {
      return Material(
        color: LightColor.secondaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX12,
              vertical: AppDimens.paddingX8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.add_rounded,
                  size: AppDimens.sizeX16,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: AppDimens.paddingX4),
                Text(
                  'Add',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: () => onChanged(quantity - 1),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: AppDimens.sizeX30),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.secondaryColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: AppDimens.sizeX32,
          height: AppDimens.sizeX32,
          child: Icon(
            icon,
            size: AppDimens.sizeX18,
            color: LightColor.inverseTextColor,
          ),
        ),
      ),
    );
  }
}

class _CartLoading extends StatelessWidget {
  const _CartLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX40),
      child: Center(
        child: SizedBox(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: LightColor.secondaryColor,
          ),
        ),
      ),
    );
  }
}

class _CartMessage extends StatelessWidget {
  const _CartMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX56,
            height: AppDimens.sizeX56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppDimens.sizeX28),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            title,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppDimens.paddingX16),
            SizedBox(
              width: AppDimens.sizeX120,
              child: CustomButton(
                text: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                minHeight: AppDimens.sizeX40,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

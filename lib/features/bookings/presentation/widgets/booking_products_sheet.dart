import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/products/data/model/product_models.dart';

/// Whether a booking is eligible for adding products (only confirmed &
/// completed bookings can have products/add-ons attached to them).
bool bookingSupportsProducts(BookingModel booking) {
  return booking.status == BookingStatus.confirmed ||
      booking.status == BookingStatus.completed;
}

/// Whether a booking can be marked as completed (only confirmed bookings).
bool bookingCanComplete(BookingModel booking) {
  return booking.status == BookingStatus.confirmed;
}

/// Payment type collected when completing a booking.
enum BookingPaymentType {
  cash,
  online;

  /// Value sent to the API (`payment_type`).
  String get apiValue => name;

  String get label => this == BookingPaymentType.cash ? 'Cash' : 'Online';

  IconData get icon => this == BookingPaymentType.cash
      ? Icons.payments_rounded
      : Icons.account_balance_wallet_rounded;
}

/// Result collected from the complete-booking sheet: how the payment was
/// settled (cash/online), any discount applied, how much is being collected
/// now, and whether it is a partial settlement.
class BookingCompleteResult {
  const BookingCompleteResult({
    required this.paymentType,
    required this.discount,
    required this.amountPaid,
    required this.isPartial,
  });

  final BookingPaymentType paymentType;
  final double discount;
  final double amountPaid;
  final bool isPartial;
}

/// Marks a confirmed booking as completed, recording how the outstanding
/// amount was collected. Returns `true` on success.
Future<bool> completeBooking(
  int bookingId, {
  BookingCompleteResult? result,
}) async {
  final response = await Client.instance().getAuthManager().completeBooking(
    bookingId: bookingId,
    paymentType: result?.paymentType.apiValue,
    discount: result?.discount,
    amountPaid: result?.amountPaid,
    paymentStatus: result == null
        ? null
        : (result.isPartial ? 'partial' : 'full'),
  );
  return response.isSuccess();
}

/// Bottom sheet shown before marking a booking as completed. Presents the
/// booking payment, the extra-item payment breakdown, a discount field, a
/// full/partial payment option and a cash/online payment type selector.
/// Returns the collected [BookingCompleteResult] on confirm, or null when the
/// vendor dismisses it.
Future<BookingCompleteResult?> showBookingCompleteSheet(
  BuildContext context,
  BookingModel booking,
) {
  return showAppBottomSheet<BookingCompleteResult>(
    context: context,
    builder: (_) => _CompleteBookingSheet(booking: booking),
  );
}

/// Opens the products cart bottom sheet for a booking. Returns `true` when at
/// least one product was successfully added.
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

// ─── Entry-point tile shown on the booking details page ───────────────────────

class BookingProductsSection extends StatelessWidget {
  const BookingProductsSection({
    super.key,
    required this.booking,
    this.onChanged,
  });

  final BookingModel booking;

  /// Called after products are successfully added, so the caller can refresh.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
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
          padding: const EdgeInsets.all(AppDimens.paddingX16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.22),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                LightColor.secondaryColor.withValues(alpha: 0.08),
                LightColor.secondaryColor.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX44,
                height: AppDimens.sizeX44,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX20,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Add products',
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
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
              const Icon(
                Icons.chevron_right_rounded,
                color: LightColor.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact chip used on the booking list card as a quick entry-point.
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

  /// Unit price for a product id — prefers the loaded product, falling back to
  /// the price carried by the booking's existing extra items (so the total is
  /// correct even before the venue products finish loading).
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX10,
              vertical: AppDimens.paddingX4,
            ),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$_itemCount item${_itemCount == 1 ? '' : 's'}',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.whiteColor,
                fontWeight: FontWeight.w700,
              ),
            ),
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
          const Divider(height: 1, color: LightColor.dividerColor),
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
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w800,
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

String _formatMoney(double amount) {
  final bool hasDecimals = amount % 1 != 0;
  return 'Rs. ${amount.toStringAsFixed(hasDecimals ? 2 : 0)}';
}

class _CompleteBookingSheet extends StatefulWidget {
  const _CompleteBookingSheet({required this.booking});

  final BookingModel booking;

  @override
  State<_CompleteBookingSheet> createState() => _CompleteBookingSheetState();
}

class _CompleteBookingSheetState extends State<_CompleteBookingSheet> {
  BookingPaymentType _paymentType = BookingPaymentType.cash;
  bool _isPartial = false;

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  BookingModel get _booking => widget.booking;

  /// Gross amount owed before any completion-time discount.
  double get _totalToCollect => _booking.balanceDue + _booking.extraItemsTotal;

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '')) ?? 0;

  /// Discount clamped to the range [0, totalToCollect].
  double get _discount => _parse(_discountController).clamp(0, _totalToCollect);

  /// Net amount payable after the discount.
  double get _netPayable => (_totalToCollect - _discount).clamp(0, double.infinity);

  /// Amount being collected right now.
  double get _amountPaid =>
      _isPartial ? _parse(_amountController).clamp(0, _netPayable) : _netPayable;

  /// Amount still owed after this settlement.
  double get _remaining =>
      (_netPayable - _amountPaid).clamp(0, double.infinity);

  bool get _canComplete =>
      !_isPartial || (_amountPaid > 0 && _amountPaid <= _netPayable);

  @override
  void dispose() {
    _discountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onComplete() {
    Navigator.of(context).pop(
      BookingCompleteResult(
        paymentType: _paymentType,
        discount: _discount,
        amountPaid: _amountPaid,
        isPartial: _isPartial && _remaining > 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX42,
                height: AppDimens.sizeX42,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX20,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Complete booking',
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingX2),
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
            ],
          ),
          const SizedBox(height: AppDimens.paddingX18),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppDimens.paddingX18),

                  _SectionLabel('Payment option'),
                  const SizedBox(height: AppDimens.paddingX8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _ChoiceOption(
                          icon: Icons.check_circle_rounded,
                          label: 'Full payment',
                          isSelected: !_isPartial,
                          onTap: () => setState(() => _isPartial = false),
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX10),
                      Expanded(
                        child: _ChoiceOption(
                          icon: Icons.timelapse_rounded,
                          label: 'Partial',
                          isSelected: _isPartial,
                          onTap: () => setState(() => _isPartial = true),
                        ),
                      ),
                    ],
                  ),
                  if (_isPartial) ...<Widget>[
                    const SizedBox(height: AppDimens.paddingX12),
                    CustomTextField(
                      controller: _amountController,
                      labelText: 'Amount received now',
                      hintText: 'Max ${_formatMoney(_netPayable)}',
                      icon: Icons.payments_outlined,
                      isRequired: false,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: AppDimens.paddingX14),
                  _SettlementSummary(
                    discount: _discount,
                    netPayable: _netPayable,
                    collectingNow: _amountPaid,
                    remaining: _remaining,
                  ),
                  const SizedBox(height: AppDimens.paddingX18),

                  _SectionLabel('Payment type'),
                  const SizedBox(height: AppDimens.paddingX8),
                  Row(
                    children: <Widget>[
                      for (final BookingPaymentType type
                          in BookingPaymentType.values) ...<Widget>[
                        Expanded(
                          child: _PaymentTypeOption(
                            type: type,
                            isSelected: _paymentType == type,
                            onTap: () => setState(() => _paymentType = type),
                          ),
                        ),
                        if (type != BookingPaymentType.values.last)
                          const SizedBox(width: AppDimens.paddingX10),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          const Divider(height: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.paddingX12),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  isOutlined: true,
                  foregroundColor: LightColor.secondaryTextColor,
                  borderColor: LightColor.dividerColor,
                  minHeight: AppDimens.sizeX48,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: CustomButton(
                  text: 'Complete',
                  icon: Icons.check_rounded,
                  backgroundColor: LightColor.purpleColor,
                  minHeight: AppDimens.sizeX48,
                  onPressed: _canComplete ? _onComplete : null,
                ),
              ),
            ],
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
      style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
        color: LightColor.primaryTextColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: isSelected
          ? LightColor.secondaryColor.withValues(alpha: 0.12)
          : LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.paddingX14,
            horizontal: AppDimens.paddingX12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX18,
                color: isSelected
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: isSelected
                        ? LightColor.secondaryColor
                        : LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live settlement summary: discount, net payable, amount collected now and
/// the remaining balance after this completion.
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
        color: LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.25),
        ),
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
        ? LightColor.redColor
        : (emphasize
              ? LightColor.secondaryColor
              : LightColor.primaryTextColor);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatMoney(amount),
            style: textTheme.bodyTextSmall?.copyWith(
              color: valueColor,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single receipt-style card: booking payment lines, an optional extra-item
/// section, and the emphasized total to collect — one clean surface instead of
/// several stacked boxes.
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
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _ReceiptSectionLabel('Booking payment'),
          const SizedBox(height: AppDimens.paddingX10),
          _ReceiptRow(label: 'Booking amount', amount: booking.amount),
          if (booking.discountAmount > 0)
            _ReceiptRow(label: 'Discount', amount: -booking.discountAmount),
          if (booking.taxAmount > 0)
            _ReceiptRow(label: 'Tax', amount: booking.taxAmount),
          if (booking.paidAmount > 0)
            _ReceiptRow(label: 'Already paid', amount: booking.paidAmount),
          _ReceiptRow(
            label: 'Balance due',
            amount: booking.balanceDue,
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
                      ?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX10),
          if (items.isEmpty)
            Text(
              'No extra items on this booking.',
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX12,
              vertical: AppDimens.paddingX12,
            ),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Total to collect',
                    style: FutsalTheme.getTextTheme(context).bodyTextMedium
                        ?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  _formatMoney(totalToCollect),
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
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
      text.toUpperCase(),
      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
        color: LightColor.secondaryTextColor,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
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
                    color: emphasize
                        ? LightColor.primaryTextColor
                        : labelColor,
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
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTypeOption extends StatelessWidget {
  const _PaymentTypeOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final BookingPaymentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: isSelected
          ? LightColor.secondaryColor.withValues(alpha: 0.12)
          : LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.paddingX14,
            horizontal: AppDimens.paddingX12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                type.icon,
                size: AppDimens.sizeX18,
                color: isSelected
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Text(
                type.label,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: isSelected
                      ? LightColor.secondaryColor
                      : LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: selected
            ? LightColor.secondaryColor.withValues(alpha: 0.06)
            : LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: selected
              ? LightColor.secondaryColor.withValues(alpha: 0.45)
              : LightColor.dividerColor,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  '${product.formattedPrice} each',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                if (selected) ...<Widget>[
                  const SizedBox(height: AppDimens.paddingX6),
                  Text(
                    'Subtotal ${_formatMoney(calculatedAmount)}',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w700,
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
            color: LightColor.whiteColor,
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

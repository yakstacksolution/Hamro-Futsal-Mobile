import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_futsal/core/widgets/custom_switch_widget.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/products/data/model/product_models.dart';
import 'package:hamro_futsal/features/products/data/repositories/products_repository_impl.dart';
import 'package:hamro_futsal/features/products/domain/repository/products_repository.dart';
import 'package:hamro_futsal/features/products/domain/usecase/products_usecase.dart';
import 'package:hamro_futsal/features/products/presentation/bloc/products_bloc.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key, this.repository});

  final ProductsRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsBloc>(
      create: (_) =>
          ProductsBloc(ProductsUseCase(repository ?? ProductsRepositoryImpl()))
            ..add(const LoadProductsBootstrapEvent()),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView();

  Future<void> _openProductForm(
    BuildContext context, {
    ProductModel? product,
  }) async {
    final ProductsState state = context.read<ProductsBloc>().state;
    final ProductVenueModel? venue = state.selectedVenue;
    if (venue == null) {
      AppUtils().showSnackBar(context, MsgType.info, 'Select a venue first.');
      return;
    }
    // Phone: a bottom sheet. Tablet / desktop: a centred dialog — a sheet
    // spanning a wide window put two short fields a screen's width apart.
    final ProductPayload? payload = context.isTabletOrWider
        ? await showDialog<ProductPayload>(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: LightColor.cardColor,
              surfaceTintColor: LightColor.transparentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX18),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _ProductFormSheet(
                  venueId: venue.id,
                  product: product,
                  asDialog: true,
                ),
              ),
            ),
          )
        : await showModalBottomSheet<ProductPayload>(
            context: context,
            isScrollControlled: true,
            backgroundColor: LightColor.cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusX18),
              ),
            ),
            builder: (_) =>
                _ProductFormSheet(venueId: venue.id, product: product),
          );
    if (payload == null || !context.mounted) return;
    if (product == null) {
      context.read<ProductsBloc>().add(CreateProductEvent(payload));
    } else {
      context.read<ProductsBloc>().add(
        UpdateProductEvent(productId: product.id, payload: payload),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: LightColor.cardColor,
          surfaceTintColor: LightColor.transparentColor,
          title: Text(
            'Delete product?',
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'This will remove ${product.name} from your products.',
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
          ),
          actions: <Widget>[
            SizedBox(
              width: AppDimens.sizeX100,
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                foregroundColor: LightColor.secondaryTextColor,
                borderColor: LightColor.dividerColor,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            SizedBox(
              width: AppDimens.sizeX100,
              child: CustomButton(
                text: 'Delete',
                backgroundColor: LightColor.redColor,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<ProductsBloc>().add(DeleteProductEvent(product.id));
    }
  }

  Widget _tile(BuildContext context, ProductsState state, int i) {
    return _ProductTile(
      key: ValueKey<int>(state.products[i].id),
      number: i + 1,
      product: state.products[i],
      onEdit: () => _openProductForm(context, product: state.products[i]),
      onDelete: () => _confirmDelete(context, state.products[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        final String? message = state.message;
        if (message == null || message.isEmpty) return;
        final MsgType type =
            state.actionStatus == ProductsActionStatus.failure ||
                state.status == ProductsStatus.failure
            ? MsgType.error
            : state.actionStatus == ProductsActionStatus.success
            ? MsgType.success
            : MsgType.info;
        AppUtils().showSnackBar(context, type, message);
      },
      builder: (context, state) {
        final bool hasVenue = state.selectedVenue != null;
        return Scaffold(
          backgroundColor: LightColor.background,
          appBar: CustomAppBar(
            title: 'Products',
            actions: <Widget>[
              IconButton(
                onPressed: hasVenue && state.status != ProductsStatus.loading
                    ? () => context.read<ProductsBloc>().add(
                        LoadProductsEvent(
                          venueId: state.selectedVenue!.id,
                          silent: true,
                        ),
                      )
                    : null,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ],
          ),
          // Tablet / desktop put "New product" in the page header instead.
          floatingActionButton: context.isTabletOrWider
              ? null
              : FloatingActionButton(
                  backgroundColor: LightColor.secondaryColor,
                  foregroundColor: LightColor.inverseTextColor,
                  shape: const CircleBorder(),
                  onPressed: hasVenue ? () => _openProductForm(context) : null,
                  child: const Icon(Icons.add_rounded),
                ),
          body: SafeArea(
            top: false,
            child: RefreshIndicator(
              color: LightColor.secondaryColor,
              onRefresh: () async {
                final ProductsBloc bloc = context.read<ProductsBloc>();
                final ProductVenueModel? venue = bloc.state.selectedVenue;
                if (venue == null) return;
                bloc.add(LoadProductsEvent(venueId: venue.id, silent: true));
                await bloc.stream
                    .firstWhere((ProductsState state) => !state.refreshing)
                    .timeout(
                      const Duration(seconds: 15),
                      onTimeout: () => bloc.state,
                    );
              },
              child: context.isTabletOrWider
                  ? _ProductsDashboard(
                      state: state,
                      onCreate: hasVenue
                          ? () => _openProductForm(context)
                          : null,
                      onEdit: (ProductModel p) =>
                          _openProductForm(context, product: p),
                      onDelete: (ProductModel p) => _confirmDelete(context, p),
                      onRetry: () => context.read<ProductsBloc>().add(
                        const LoadProductsBootstrapEvent(),
                      ),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.paddingX20,
                        AppDimens.paddingX16,
                        AppDimens.paddingX20,
                        AppDimens.paddingX50 * 2,
                      ),
                      children: <Widget>[
                        _ProductsSummary(count: state.products.length),
                        const SizedBox(height: AppDimens.paddingX16),
                        _VenueSelector(state: state),
                        const SizedBox(height: AppDimens.paddingX18),
                        _ProductsHeader(refreshing: state.refreshing),
                        const SizedBox(height: AppDimens.paddingX10),
                        if (state.status == ProductsStatus.loading)
                          const _ProductsLoading()
                        else if (state.status == ProductsStatus.failure &&
                            state.products.isEmpty)
                          _ProductsError(
                            onRetry: () => context.read<ProductsBloc>().add(
                              const LoadProductsBootstrapEvent(),
                            ),
                          )
                        else if (state.products.isEmpty)
                          const _EmptyProducts()
                        else
                          for (
                            int i = 0;
                            i < state.products.length;
                            i++
                          ) ...<Widget>[
                            _tile(context, state, i),
                            const SizedBox(height: AppDimens.paddingX10),
                          ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductsSummary extends StatelessWidget {
  const _ProductsSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX48,
            height: AppDimens.sizeX48,
            decoration: BoxDecoration(
              color: LightColor.inverseTextColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: LightColor.inverseTextColor,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$count products',
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        color: LightColor.inverseTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  'Manage product name, price and active status per venue.',
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: LightColor.inverseTextColor.withValues(
                          alpha: 0.78,
                        ),
                        height: 1.35,
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

class _VenueSelector extends StatelessWidget {
  const _VenueSelector({required this.state});

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownField<int>(
      labelText: 'Venue',
      hintText: state.venues.isEmpty ? 'No venues found' : 'Select venue',
      icon: Icons.stadium_outlined,
      initialValue: state.selectedVenue?.id,
      enabled: state.venues.isNotEmpty,
      items: state.venues
          .map(
            (ProductVenueModel venue) => DropdownMenuItem<int>(
              value: venue.id,
              child: Text(venue.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: (int? value) {
        if (value == null) return;
        context.read<ProductsBloc>().add(SelectProductVenueEvent(value));
      },
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({required this.refreshing});

  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Product list',
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: AppDimens.sizeX18,
          height: AppDimens.sizeX18,
          child: refreshing
              ? const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: LightColor.secondaryColor,
                )
              : null,
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    super.key,
    required this.number,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool active = product.isActive;
    final Color statusColor = active
        ? LightColor.secondaryColor
        : LightColor.secondaryTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX14,
        vertical: AppDimens.paddingX12,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX44,
            height: AppDimens.sizeX44,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shopping_bag_outlined,
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
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                Row(
                  children: <Widget>[
                    Text(
                      product.formattedPrice,
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: AppDimens.paddingX8),
                    Container(
                      width: AppDimens.sizeX4,
                      height: AppDimens.sizeX4,
                      decoration: BoxDecoration(
                        color: LightColor.iconGrey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingX8),
                    Text(
                      active ? 'Active' : 'Inactive',
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX4),
          IconButton(
            tooltip: 'Edit product',
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.edit_outlined,
              color: LightColor.secondaryTextColor,
              size: AppDimens.sizeX20,
            ),
          ),
          IconButton(
            tooltip: 'Delete product',
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: LightColor.redColor,
              size: AppDimens.sizeX20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  const _ProductFormSheet({
    required this.venueId,
    this.product,
    this.asDialog = false,
  });

  final int venueId;
  final ProductModel? product;

  final bool asDialog;

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late bool _isActive;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toStringAsFixed(0) ?? '',
    );
    _isActive = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      ProductPayload(
        venueId: widget.venueId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final double bottomPadding = widget.asDialog
        ? AppDimens.paddingX8
        : viewInsets.bottom > 0
        ? viewInsets.bottom
        : AppDimens.paddingX16;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: widget.asDialog
                ? const EdgeInsets.fromLTRB(
                    AppDimens.paddingX24,
                    AppDimens.paddingX20,
                    AppDimens.paddingX24,
                    AppDimens.paddingX16,
                  )
                : const EdgeInsets.fromLTRB(
                    AppDimens.paddingX20,
                    AppDimens.paddingX16,
                    AppDimens.paddingX20,
                    AppDimens.paddingX8,
                  ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (!widget.asDialog) ...<Widget>[
                    Center(
                      child: Container(
                        width: AppDimens.sizeX40,
                        height: AppDimens.sizeX4,
                        decoration: BoxDecoration(
                          color: LightColor.dividerColor,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingX18),
                  ],
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _isEditing ? 'Update product' : 'Create product',
                          style: FutsalTheme.getTextTheme(context).bodyTextLarge
                              ?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      if (widget.asDialog)
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: LightColor.secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX18),
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Product name',
                    hintText: 'Water bottle',
                    icon: Icons.shopping_bag_outlined,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    ensureVisibleOnFocus: true,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.paddingX14),
                  CustomTextField(
                    controller: _priceController,
                    labelText: 'Price',
                    hintText: '50',
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    textInputAction: TextInputAction.done,
                    ensureVisibleOnFocus: true,
                    validator: (String? value) {
                      final double? price = double.tryParse(
                        value?.trim() ?? '',
                      );
                      if (price == null || price <= 0) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AppDimens.paddingX16),
                  _ActiveSwitchTile(
                    value: _isActive,
                    onChanged: (bool value) =>
                        setState(() => _isActive = value),
                  ),
                  const SizedBox(height: AppDimens.paddingX22),
                  CustomButton(
                    text: _isEditing ? 'Update product' : 'Create product',
                    icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveSwitchTile extends StatelessWidget {
  const _ActiveSwitchTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Active product',
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppDimens.paddingX2),
                Text(
                  value ? 'Visible for sale' : 'Hidden from sale',
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
          CustomSwitchWidget(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProductsLoading extends StatelessWidget {
  const _ProductsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX30),
      child: Center(
        child: SizedBox(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: LightColor.secondaryColor,
            backgroundColor: LightColor.secondaryColor.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}

class _ProductsError extends StatelessWidget {
  const _ProductsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX24),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: LightColor.redColor,
            size: AppDimens.sizeX36,
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            'Could not load products',
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          CustomButton(
            text: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX24),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX56,
            height: AppDimens.sizeX56,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            'No products yet',
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            'Tap Create to add your first product.',
            textAlign: TextAlign.center,
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _ProductsDashboard extends StatefulWidget {
  const _ProductsDashboard({
    required this.state,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onRetry,
  });

  final ProductsState state;
  final VoidCallback? onCreate;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;
  final VoidCallback onRetry;

  @override
  State<_ProductsDashboard> createState() => _ProductsDashboardState();
}

enum _StatusFilter { all, active, inactive }

class _ProductsDashboardState extends State<_ProductsDashboard> {
  final TextEditingController _search = TextEditingController();
  _StatusFilter _filter = _StatusFilter.all;

  static const double _maxWidth = 1160;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProductModel> _visible(List<ProductModel> all) {
    final String q = _search.text.trim().toLowerCase();
    return all
        .where((ProductModel p) {
          final bool statusOk = switch (_filter) {
            _StatusFilter.all => true,
            _StatusFilter.active => p.isActive,
            _StatusFilter.inactive => !p.isActive,
          };
          return statusOk && (q.isEmpty || p.name.toLowerCase().contains(q));
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final ProductsState state = widget.state;
    final List<ProductModel> products = state.products;
    final int active = products.where((ProductModel p) => p.isActive).length;
    final double avg = products.isEmpty
        ? 0
        : products.fold<double>(0, (double s, ProductModel p) => s + p.price) /
              products.length;
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool desktop = context.isDesktop;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX24,
        AppDimens.paddingX20,
        AppDimens.paddingX24,
        AppDimens.paddingX40,
      ),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ── Header: title, venue picker, primary action ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Products',
                            style: textTheme.headingSmall?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppDimens.paddingX4),
                          Text(
                            state.selectedVenue == null
                                ? 'Select a venue to manage its products'
                                : 'Items you sell at ${state.selectedVenue!.name}',
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingX16),
                    SizedBox(
                      width: desktop ? 300 : 240,
                      child: _VenueSelector(state: state),
                    ),
                    const SizedBox(width: AppDimens.paddingX12),
                    SizedBox(
                      height: AppDimens.sizeX48,
                      child: CustomButton(
                        text: 'New product',
                        icon: Icons.add_rounded,
                        minWidth: 150,
                        onPressed: widget.onCreate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX20),

                // ── Summary figures ──
                Row(
                  children: <Widget>[
                    for (final (int i, (String, String, IconData, Color) s)
                        in <(String, String, IconData, Color)>[
                          (
                            'Total products',
                            '${products.length}',
                            Icons.inventory_2_outlined,
                            LightColor.secondaryColor,
                          ),
                          (
                            'Active',
                            '$active',
                            Icons.check_circle_outline_rounded,
                            LightColor.secondaryColor,
                          ),
                          (
                            'Inactive',
                            '${products.length - active}',
                            Icons.pause_circle_outline_rounded,
                            LightColor.warningColor,
                          ),
                          (
                            'Average price',
                            Money.npr(avg),
                            Icons.payments_outlined,
                            LightColor.secondaryColor,
                          ),
                        ].indexed) ...<Widget>[
                      if (i > 0) const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: _StatTile(
                          label: s.$1,
                          value: s.$2,
                          icon: s.$3,
                          color: s.$4,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX20),

                // ── Table card ──
                Container(
                  decoration: BoxDecoration(
                    color: LightColor.cardColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                    border: Border.all(color: LightColor.dividerColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Toolbar: search + status filter.
                      Padding(
                        padding: const EdgeInsets.all(AppDimens.paddingX14),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: TextField(
                                  controller: _search,
                                  onChanged: (_) => setState(() {}),
                                  style: textTheme.bodyTextSmall?.copyWith(
                                    color: LightColor.primaryTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search products',
                                    hintStyle: textTheme.bodyTextSmall
                                        ?.copyWith(
                                          color: LightColor.hintTextColor,
                                        ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: AppDimens.sizeX20,
                                      color: LightColor.hintTextColor,
                                    ),
                                    filled: true,
                                    fillColor: LightColor.inputFillColor,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.radiusX10,
                                      ),
                                      borderSide: BorderSide(
                                        color: LightColor.dividerColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.radiusX10,
                                      ),
                                      borderSide: BorderSide(
                                        color: LightColor.dividerColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingX12),
                            _FilterTabs(
                              value: _filter,
                              counts: <int>[
                                products.length,
                                active,
                                products.length - active,
                              ],
                              onChanged: (_StatusFilter f) =>
                                  setState(() => _filter = f),
                            ),
                            if (state.refreshing) ...<Widget>[
                              const SizedBox(width: AppDimens.paddingX12),
                              const SizedBox(
                                width: AppDimens.sizeX18,
                                height: AppDimens.sizeX18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: LightColor.secondaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Divider(height: 1, color: LightColor.dividerColor),
                      ..._tableBody(context, state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _tableBody(BuildContext context, ProductsState state) {
    if (state.status == ProductsStatus.loading) {
      return const <Widget>[_ProductsLoading()];
    }
    if (state.status == ProductsStatus.failure && state.products.isEmpty) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppDimens.paddingX16),
          child: _ProductsError(onRetry: widget.onRetry),
        ),
      ];
    }
    if (state.products.isEmpty) {
      return const <Widget>[
        Padding(
          padding: EdgeInsets.all(AppDimens.paddingX16),
          child: _EmptyProducts(),
        ),
      ];
    }
    final List<ProductModel> rows = _visible(state.products);
    return <Widget>[
      const _TableHeader(),
      if (rows.isEmpty)
        Padding(
          padding: const EdgeInsets.all(AppDimens.paddingX32),
          child: Center(
            child: Text(
              'No products match your search.',
              style: FutsalTheme.getTextTheme(
                context,
              ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
            ),
          ),
        )
      else
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          if (i > 0) Divider(height: 1, color: LightColor.dividerColor),
          _ProductRow(
            key: ValueKey<int>(rows[i].id),
            number: i + 1,
            product: rows[i],
            onEdit: () => widget.onEdit(rows[i]),
            onDelete: () => widget.onDelete(rows[i]),
          ),
        ],
    ];
  }
}

const int _kColNumber = 1;
const int _kColName = 6;
const int _kColPrice = 3;
const int _kColStatus = 3;
const double _kColActions = 96;

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = FutsalTheme.getTextTheme(context).bodyMiniSubTitle
        ?.copyWith(
          color: LightColor.hintTextColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        );
    Widget cell(String text, int flex, {TextAlign align = TextAlign.start}) =>
        Expanded(
          flex: flex,
          child: Text(text.toUpperCase(), textAlign: align, style: style),
        );
    return Container(
      color: LightColor.inputFillColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX10,
      ),
      child: Row(
        children: <Widget>[
          cell('#', _kColNumber),
          cell('Product', _kColName),
          cell('Price', _kColPrice),
          cell('Status', _kColStatus),
          SizedBox(
            width: _kColActions,
            child: Text('ACTIONS', textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatefulWidget {
  const _ProductRow({
    super.key,
    required this.number,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final ProductModel p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: _hover
            ? LightColor.secondaryColor.withValues(alpha: 0.04)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX12,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: _kColNumber,
                  child: Text(
                    '${widget.number}',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: _kColName,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: AppDimens.sizeX36,
                        height: AppDimens.sizeX36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: LightColor.secondaryColor.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX8,
                          ),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: AppDimens.sizeX18,
                          color: LightColor.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: _kColPrice,
                  child: Text(
                    p.formattedPrice,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: _kColStatus,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _StatusPill(active: p.isActive),
                  ),
                ),
                SizedBox(
                  width: _kColActions,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Edit product',
                        visualDensity: VisualDensity.compact,
                        onPressed: widget.onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: AppDimens.sizeX18,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete product',
                        visualDensity: VisualDensity.compact,
                        onPressed: widget.onDelete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: AppDimens.sizeX18,
                          color: LightColor.redColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? LightColor.secondaryColor
        : LightColor.secondaryTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimens.paddingX6),
          Text(
            active ? 'Active' : 'Inactive',
            style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX40,
            height: AppDimens.sizeX40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Icon(icon, size: AppDimens.sizeX20, color: color),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.value,
    required this.counts,
    required this.onChanged,
  });

  final _StatusFilter value;
  final List<int> counts;
  final ValueChanged<_StatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    const List<String> labels = <String>['All', 'Active', 'Inactive'];
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final _StatusFilter f in _StatusFilter.values)
            GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX14,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: f == value ? LightColor.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  boxShadow: f == value
                      ? <BoxShadow>[
                          BoxShadow(
                            color: LightColor.shadowOf(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${labels[f.index]}  ${counts[f.index]}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: f == value
                        ? LightColor.primaryTextColor
                        : LightColor.secondaryTextColor,
                    fontWeight: f == value ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

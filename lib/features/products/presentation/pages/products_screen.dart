import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_futsal/core/widgets/custom_switch_widget.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/products/data/model/product_models.dart';
import 'package:hamro_futsal/features/products/data/repositories/products_repository_impl.dart';
import 'package:hamro_futsal/features/products/domain/usecase/products_usecase.dart';
import 'package:hamro_futsal/features/products/presentation/bloc/products_bloc.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsBloc>(
      create: (_) =>
          ProductsBloc(ProductsUseCase(ProductsRepositoryImpl()))
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
    final ProductPayload? payload = await showModalBottomSheet<ProductPayload>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX18),
        ),
      ),
      builder: (_) => _ProductFormSheet(venueId: venue.id, product: product),
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
          floatingActionButton: FloatingActionButton(
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
              child: ListView(
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
                    for (int i = 0; i < state.products.length; i++) ...<Widget>[
                      _ProductTile(
                        key: ValueKey<int>(state.products[i].id),
                        number: i + 1,
                        product: state.products[i],
                        onEdit: () => _openProductForm(
                          context,
                          product: state.products[i],
                        ),
                        onDelete: () =>
                            _confirmDelete(context, state.products[i]),
                      ),
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
  const _ProductFormSheet({required this.venueId, this.product});

  final int venueId;
  final ProductModel? product;

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
    final double bottomPadding = viewInsets.bottom > 0
        ? viewInsets.bottom
        : AppDimens.paddingX16;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
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
                  Center(
                    child: Container(
                      width: AppDimens.sizeX40,
                      height: AppDimens.sizeX4,
                      decoration: BoxDecoration(
                        color: LightColor.dividerColor,
                        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX18),
                  Text(
                    _isEditing ? 'Update product' : 'Create product',
                    style: FutsalTheme.getTextTheme(context).bodyTextLarge
                        ?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
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

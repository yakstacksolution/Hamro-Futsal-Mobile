part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, success, failure }

enum ProductsActionStatus { initial, loading, success, failure }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.initial,
    this.actionStatus = ProductsActionStatus.initial,
    this.refreshing = false,
    this.venues = const <ProductVenueModel>[],
    this.selectedVenue,
    this.products = const <ProductModel>[],
    this.message,
  });

  final ProductsStatus status;
  final ProductsActionStatus actionStatus;
  final bool refreshing;
  final List<ProductVenueModel> venues;
  final ProductVenueModel? selectedVenue;
  final List<ProductModel> products;
  final String? message;

  ProductsState copyWith({
    ProductsStatus? status,
    ProductsActionStatus? actionStatus,
    bool? refreshing,
    List<ProductVenueModel>? venues,
    ProductVenueModel? selectedVenue,
    List<ProductModel>? products,
    String? message,
    bool clearMessage = false,
  }) {
    return ProductsState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? ProductsActionStatus.initial,
      refreshing: refreshing ?? this.refreshing,
      venues: venues ?? this.venues,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      products: products ?? this.products,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    actionStatus,
    refreshing,
    venues,
    selectedVenue,
    products,
    message,
  ];
}

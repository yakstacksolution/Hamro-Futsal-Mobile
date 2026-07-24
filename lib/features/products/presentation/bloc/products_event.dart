part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoadProductsBootstrapEvent extends ProductsEvent {
  const LoadProductsBootstrapEvent();
}

final class SelectProductVenueEvent extends ProductsEvent {
  const SelectProductVenueEvent(this.venueId);

  final int venueId;

  @override
  List<Object?> get props => <Object?>[venueId];
}

final class LoadProductsEvent extends ProductsEvent {
  const LoadProductsEvent({required this.venueId, this.silent = false});

  final int venueId;
  final bool silent;

  @override
  List<Object?> get props => <Object?>[venueId, silent];
}

final class CreateProductEvent extends ProductsEvent {
  const CreateProductEvent(this.payload);

  final ProductPayload payload;

  @override
  List<Object?> get props => <Object?>[payload];
}

final class UpdateProductEvent extends ProductsEvent {
  const UpdateProductEvent({required this.productId, required this.payload});

  final int productId;
  final ProductPayload payload;

  @override
  List<Object?> get props => <Object?>[productId, payload];
}

final class DeleteProductEvent extends ProductsEvent {
  const DeleteProductEvent(this.productId);

  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}

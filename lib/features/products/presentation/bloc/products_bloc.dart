import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/products/data/model/product_models.dart';
import 'package:hamro_footsall/features/products/domain/usecase/products_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this.useCase) : super(const ProductsState()) {
    on<LoadProductsBootstrapEvent>(_onBootstrap);
    on<SelectProductVenueEvent>(_onSelectVenue);
    on<LoadProductsEvent>(_onLoadProducts);
    on<CreateProductEvent>(_onCreate);
    on<UpdateProductEvent>(_onUpdate);
    on<DeleteProductEvent>(_onDelete);
  }

  final ProductsUseCase useCase;

  Future<void> _onBootstrap(
    LoadProductsBootstrapEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(status: ProductsStatus.loading, clearMessage: true));
    final venuesResult = await useCase.getVenues();
    await venuesResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: ProductsStatus.failure,
          message: failure.errorMessage,
        ),
      ),
      (venues) async {
        if (venues.isEmpty) {
          emit(
            state.copyWith(
              status: ProductsStatus.success,
              venues: venues,
              products: const <ProductModel>[],
              message: 'No venues found for products.',
            ),
          );
          return;
        }
        final selected = venues.first;
        final productsResult = await useCase.getProducts(venueId: selected.id);
        productsResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ProductsStatus.failure,
              venues: venues,
              selectedVenue: selected,
              message: failure.errorMessage,
            ),
          ),
          (products) => emit(
            state.copyWith(
              status: ProductsStatus.success,
              venues: venues,
              selectedVenue: selected,
              products: products,
              clearMessage: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSelectVenue(
    SelectProductVenueEvent event,
    Emitter<ProductsState> emit,
  ) async {
    ProductVenueModel? venue;
    for (final ProductVenueModel item in state.venues) {
      if (item.id == event.venueId) {
        venue = item;
        break;
      }
    }
    if (venue == null) return;
    emit(state.copyWith(selectedVenue: venue));
    add(LoadProductsEvent(venueId: venue.id));
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: event.silent ? state.status : ProductsStatus.loading,
        refreshing: event.silent,
        clearMessage: true,
      ),
    );
    final result = await useCase.getProducts(venueId: event.venueId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductsStatus.failure,
          refreshing: false,
          message: failure.errorMessage,
        ),
      ),
      (products) => emit(
        state.copyWith(
          status: ProductsStatus.success,
          refreshing: false,
          products: products,
          clearMessage: true,
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ProductsActionStatus.loading));
    final result = await useCase.createProduct(event.payload);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ProductsActionStatus.failure,
          message: failure.errorMessage,
        ),
      ),
      (product) {
        final products = <ProductModel>[product, ...state.products];
        emit(
          state.copyWith(
            status: ProductsStatus.success,
            actionStatus: ProductsActionStatus.success,
            products: products,
            message: 'Product created successfully.',
          ),
        );
        add(LoadProductsEvent(venueId: event.payload.venueId, silent: true));
      },
    );
  }

  Future<void> _onUpdate(
    UpdateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ProductsActionStatus.loading));
    final result = await useCase.updateProduct(
      productId: event.productId,
      payload: event.payload,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ProductsActionStatus.failure,
          message: failure.errorMessage,
        ),
      ),
      (product) {
        final products = state.products
            .map((ProductModel item) => item.id == product.id ? product : item)
            .toList(growable: false);
        emit(
          state.copyWith(
            actionStatus: ProductsActionStatus.success,
            products: products,
            message: 'Product updated successfully.',
          ),
        );
        add(LoadProductsEvent(venueId: event.payload.venueId, silent: true));
      },
    );
  }

  Future<void> _onDelete(
    DeleteProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ProductsActionStatus.loading));
    final result = await useCase.deleteProduct(event.productId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ProductsActionStatus.failure,
          message: failure.errorMessage,
        ),
      ),
      (_) {
        final int? venueId = state.selectedVenue?.id;
        emit(
          state.copyWith(
            actionStatus: ProductsActionStatus.success,
            products: state.products
                .where((ProductModel item) => item.id != event.productId)
                .toList(growable: false),
            message: 'Product deleted successfully.',
          ),
        );
        if (venueId != null) {
          add(LoadProductsEvent(venueId: venueId, silent: true));
        }
      },
    );
  }
}

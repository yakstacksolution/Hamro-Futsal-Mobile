import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';

/// Optimistically flips the venue in [WishlistStore], persists via
/// `POST /venues/{venue}/wishlist`, and reverts the store on failure.
final class ToggleWishlistUseCase {
  const ToggleWishlistUseCase(this.repository);

  final PublicRepository repository;

  /// Returns the error message when the API call failed, null on success.
  Future<String?> call(int venueId) async {
    WishlistStore.instance.toggleLocal(venueId);
    final result = await repository.toggleWishlist(venueId);
    return result.fold((failure) {
      WishlistStore.instance.toggleLocal(venueId); // revert
      return failure.errorMessage;
    }, (_) => null);
  }
}

part of 'booking_hold_bloc.dart';

enum BookingHoldStatus { idle, holding, held, failure }

final class BookingHoldState extends Equatable {
  const BookingHoldState({
    this.status = BookingHoldStatus.idle,
    this.holds = const <BookingHoldModel>[],
    this.errorMessage,
  });

  final BookingHoldStatus status;

  /// Every hold returned by `POST /booking-holds` (one per session date),
  /// kept for the lifetime of the checkout page so they can be released on
  /// exit.
  final List<BookingHoldModel> holds;

  /// The first hold — its token and quote stand for the booking.
  BookingHoldModel? get hold => holds.isEmpty ? null : holds.first;
  final String? errorMessage;

  /// The booking's server price: the first hold that carries one (every hold
  /// of a recurring booking shares the same quote).
  BookingQuoteModel? get quote {
    for (final BookingHoldModel h in holds) {
      if (h.quote != null) return h.quote;
    }
    return null;
  }

  /// The hold's token, as the server sent it.
  String? get holdToken => hold?.holdToken;

  /// The ids that release the holds (`DELETE /booking-holds`, as a list).
  List<String> get holdIds => <String>[
    for (final BookingHoldModel h in holds)
      if (h.hasId) h.id!,
  ];

  bool get hasToken => hold?.hasToken ?? false;
  bool get isHolding => status == BookingHoldStatus.holding;

  BookingHoldState copyWith({
    BookingHoldStatus? status,
    List<BookingHoldModel>? holds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingHoldState(
      status: status ?? this.status,
      holds: holds ?? this.holds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, holds, errorMessage];
}

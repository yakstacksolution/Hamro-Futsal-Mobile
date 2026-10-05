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

  /// The booking's server price: the quote sent for the whole booking, when
  /// it carries figures; otherwise the holds' own quotes — one hold's, or
  /// several added up, each pricing its own slot.
  BookingQuoteModel? get quote {
    for (final BookingHoldModel h in holds) {
      final BookingQuoteModel? booking = h.bookingQuote;
      if (booking != null && booking.hasPricing) return booking;
    }
    final List<BookingQuoteModel> own = <BookingQuoteModel>[
      for (final BookingHoldModel h in holds)
        if (h.quote != null) h.quote!,
    ];
    // Holds given the booking's quote for want of their own all carry the
    // same one: it counts once, not once per hold.
    if (holds.any((BookingHoldModel h) => h.quoteIsShared)) {
      return own.isEmpty ? null : own.first;
    }
    return BookingQuoteModel.combine(own);
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

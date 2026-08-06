import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  const BookingModel({
    required this.id,
    required this.bookingRef,
    required this.courtName,
    required this.futsalName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.amount,
    this.venueId,
    this.courtId,
    this.vendorId,
    this.playerId,
    this.playerName,
    this.playerPhone,
    this.playerEmail,
    this.futsalAddress,
    this.bookingType,
    this.seriesParentId,
    this.isRecurring = false,
    this.isSeriesAnchor = false,
    this.recurrenceType,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.slotCount = 1,
    this.pricePerSlot = 0,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.completionDiscount = 0,
    this.taxAmount = 0,
    this.extraAmount = 0,
    this.advanceAmount = 0,
    this.partialAmount = 0,
    this.payableNow = 0,
    this.balanceDueLater = 0,
    this.paidAmount = 0,
    this.balanceDue = 0,
    this.paymentStatus,
    this.notes,
    this.coupon,
    this.payments = const <BookingPaymentModel>[],
    this.bookingSlots = const <BookingSlotModel>[],
    this.extraItems = const <BookingExtraItemModel>[],
    this.createdAt,
  });

  final int id;
  final String bookingRef;
  final String courtName;
  final String futsalName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final double amount;
  final int? venueId;
  final int? courtId;

  /// User id of the venue owner/vendor — used to open a chat with the venue.
  final int? vendorId;

  /// User id of the customer who made the booking — used to open a chat with
  /// the player from the vendor's futsal-bookings view.
  final int? playerId;
  final String? playerName;
  final String? playerPhone;
  final String? playerEmail;
  final String? futsalAddress;

  /// How the booking was created — `online` (player app) or `manual`
  /// (walk-in entered by the vendor).
  final String? bookingType;
  final int? seriesParentId;
  final bool isRecurring;
  final bool isSeriesAnchor;
  final String? recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final int slotCount;
  final double pricePerSlot;
  final double subtotal;
  final double discountAmount;

  /// Discount granted by the vendor at the moment the booking was completed.
  final double completionDiscount;
  final double taxAmount;

  /// Server-side total of the products attached to the booking. When this is
  /// greater than zero, `total_amount` and the balance fields already include
  /// the products — see [totalsIncludeExtras].
  final double extraAmount;
  final double advanceAmount;

  /// Partial payment recorded against the booking, when the venue accepts a
  /// custom amount instead of the fixed advance.
  final double partialAmount;
  final double payableNow;
  final double balanceDueLater;

  /// Amount already paid & verified by the server for this booking.
  final double paidAmount;

  /// Remaining amount still owed for this booking.
  final double balanceDue;
  final String? paymentStatus;
  final String? notes;
  final BookingCouponModel? coupon;
  final List<BookingPaymentModel> payments;
  final List<BookingSlotModel> bookingSlots;

  /// Products added to this booking (from the `extra_items` array).
  final List<BookingExtraItemModel> extraItems;

  /// When the booking was placed, when the API reports it.
  final DateTime? createdAt;

  /// Total number of extra product units attached to this booking.
  int get extraItemsCount => extraItems.fold<int>(
    0,
    (int sum, BookingExtraItemModel e) => sum + e.quantity,
  );

  /// Total monetary value of the extra products.
  double get extraItemsTotal => extraItems.fold<double>(
    0,
    (double sum, BookingExtraItemModel e) => sum + e.totalAmount,
  );

  /// Whether the server's `total_amount`/balance fields already account for the
  /// booked products. The API reports `extra_amount` alongside `extra_items`
  /// once products are attached, and folds it into `total_amount`.
  bool get totalsIncludeExtras => extraAmount > 0;

  /// Net court charge after booking-level discount/tax, excluding products. The
  /// API's `amount` (`total_amount`) is authoritative; the arithmetic fallback
  /// supports older payloads that only expose the individual charge fields.
  double get bookingTotal {
    if (amount > 0) return _atLeastZero(amount - extraAmount);
    return _atLeastZero(subtotal - discountAmount + taxAmount);
  }

  /// Court charge plus products sold against the booking.
  double get grandTotal {
    if (totalsIncludeExtras && amount > 0) return amount;
    return bookingTotal + extraItemsTotal;
  }

  /// Verified/settled money recorded for this booking.
  double get effectivePaidAmount {
    if (paidAmount > 0) return paidAmount;
    return payments
        .where((BookingPaymentModel payment) {
          final String status = payment.status?.trim().toLowerCase() ?? '';
          final String verification =
              payment.verificationStatus?.trim().toLowerCase() ?? '';
          return const <String>{
                'paid',
                'completed',
                'success',
                'successful',
              }.contains(status) ||
              const <String>{'accepted', 'verified'}.contains(verification);
        })
        .fold<double>(0, (double sum, payment) => sum + payment.amount);
  }

  /// Remaining court charge before completion. Products are deliberately not
  /// included here because they are added once by [amountDueForCompletion], so
  /// the server balances — which already carry `extra_amount` — are reduced by
  /// it again.
  double get remainingBookingBalance {
    final double extras = totalsIncludeExtras ? extraAmount : 0;
    if (balanceDue > 0) return _atLeastZero(balanceDue - extras);
    if (balanceDueLater > 0) return _atLeastZero(balanceDueLater - extras);
    return _atLeastZero(bookingTotal - effectivePaidAmount);
  }

  /// Amount presented when a confirmed booking is completed.
  double get amountDueForCompletion =>
      remainingBookingBalance + extraItemsTotal;

  /// Server-recorded due on a completed booking. Unlike completion, products
  /// are not added again because the completed booking's `balance_due`
  /// already represents the final outstanding settlement.
  double get amountDueForCollection {
    if (status != BookingStatus.completed) return 0;
    if (balanceDue > 0) return balanceDue;
    final String normalized = paymentStatus?.trim().toLowerCase() ?? '';
    if (normalized == 'partial' || normalized == 'partially_paid') {
      return balanceDueLater;
    }
    return 0;
  }

  /// Primary payment for this booking — the one carrying a proof screenshot if
  /// any, otherwise the first recorded payment. Null when no payments exist.
  BookingPaymentModel? get payment {
    if (payments.isEmpty) return null;
    for (final BookingPaymentModel p in payments) {
      if (p.hasPaymentProof ||
          p.paymentProofUrl?.trim().isNotEmpty == true ||
          p.paymentProofPath?.trim().isNotEmpty == true) {
        return p;
      }
    }
    return payments.first;
  }

  BookingModel copyWith({
    int? id,
    String? bookingRef,
    String? courtName,
    String? futsalName,
    DateTime? date,
    String? startTime,
    String? endTime,
    BookingStatus? status,
    double? amount,
    int? venueId,
    int? courtId,
    int? vendorId,
    int? playerId,
    String? playerName,
    String? playerPhone,
    String? playerEmail,
    String? futsalAddress,
    String? bookingType,
    int? seriesParentId,
    bool? isRecurring,
    bool? isSeriesAnchor,
    String? recurrenceType,
    DateTime? recurrenceStartDate,
    DateTime? recurrenceEndDate,
    int? slotCount,
    double? pricePerSlot,
    double? subtotal,
    double? discountAmount,
    double? completionDiscount,
    double? taxAmount,
    double? extraAmount,
    double? advanceAmount,
    double? partialAmount,
    double? payableNow,
    double? balanceDueLater,
    double? paidAmount,
    double? balanceDue,
    String? paymentStatus,
    String? notes,
    BookingCouponModel? coupon,
    List<BookingPaymentModel>? payments,
    List<BookingSlotModel>? bookingSlots,
    List<BookingExtraItemModel>? extraItems,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingRef: bookingRef ?? this.bookingRef,
      courtName: courtName ?? this.courtName,
      futsalName: futsalName ?? this.futsalName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      venueId: venueId ?? this.venueId,
      courtId: courtId ?? this.courtId,
      vendorId: vendorId ?? this.vendorId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerPhone: playerPhone ?? this.playerPhone,
      playerEmail: playerEmail ?? this.playerEmail,
      futsalAddress: futsalAddress ?? this.futsalAddress,
      bookingType: bookingType ?? this.bookingType,
      seriesParentId: seriesParentId ?? this.seriesParentId,
      isRecurring: isRecurring ?? this.isRecurring,
      isSeriesAnchor: isSeriesAnchor ?? this.isSeriesAnchor,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceStartDate: recurrenceStartDate ?? this.recurrenceStartDate,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      slotCount: slotCount ?? this.slotCount,
      pricePerSlot: pricePerSlot ?? this.pricePerSlot,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      completionDiscount: completionDiscount ?? this.completionDiscount,
      taxAmount: taxAmount ?? this.taxAmount,
      extraAmount: extraAmount ?? this.extraAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      partialAmount: partialAmount ?? this.partialAmount,
      payableNow: payableNow ?? this.payableNow,
      balanceDueLater: balanceDueLater ?? this.balanceDueLater,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      coupon: coupon ?? this.coupon,
      payments: payments ?? this.payments,
      bookingSlots: bookingSlots ?? this.bookingSlots,
      extraItems: extraItems ?? this.extraItems,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayStartTime => _displayTime(startTime);
  String get displayEndTime => _displayTime(endTime);

  String get displayTimeRange {
    if (displayStartTime.isEmpty) return '';
    if (displayEndTime.isEmpty) return displayStartTime;
    return '$displayStartTime – $displayEndTime';
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> court = _mapOf(
      json['court'] ?? json['venue_court'],
    );
    final Map<String, dynamic> venue = _mapOf(
      json['venue'] ?? json['futsal'] ?? court['venue'] ?? court['futsal'],
    );
    final Map<String, dynamic> vendor = _mapOf(
      json['vendor'] ?? json['owner'] ?? venue['vendor'] ?? venue['owner'],
    );
    final Map<String, dynamic> player = _mapOf(
      json['user'] ??
          json['player'] ??
          json['customer'] ??
          json['candidate'] ??
          json['booking_user'] ??
          json['created_by'] ??
          json['booked_by'],
    );
    final Map<String, dynamic> slot = _mapOf(
      json['slot'] ?? json['time_slot'] ?? json['slot_schedule'],
    );
    final Map<String, dynamic> totals = _mapOf(
      json['price_details'] ?? json['payment'] ?? json['quote'],
    );
    final Map<String, dynamic> coupon = _mapOf(json['coupon']);
    // The API returns a list under `payments`; older/detail payloads may still
    // send a single `payment` object — support both.
    final List<BookingPaymentModel> payments = _mapList(
      json['payments'],
    ).map(BookingPaymentModel.fromJson).toList(growable: false);
    final Map<String, dynamic> singlePayment = _mapOf(json['payment']);
    final List<BookingSlotModel> bookingSlots = _mapList(
      json['booking_slots'],
    ).map(BookingSlotModel.fromJson).toList(growable: false);
    final List<BookingExtraItemModel> extraItems = _mapList(
      json['extra_items'] ?? json['booking_extra_items'] ?? json['extras'],
    ).map(BookingExtraItemModel.fromJson).toList(growable: false);

    return BookingModel(
      id: _asInt(json['id'] ?? json['booking_id']) ?? 0,
      bookingRef:
          _asString(
            json['booking_ref'] ??
                json['booking_reference'] ??
                json['booking_number'] ??
                json['booking_code'] ??
                json['reference'],
          ) ??
          '',
      courtName:
          _asString(
            json['court_name'] ??
                json['venue_court_name'] ??
                court['name'] ??
                court['title'],
          ) ??
          '',
      futsalName:
          _asString(
            json['futsal_name'] ??
                json['venue_name'] ??
                venue['name'] ??
                venue['title'],
          ) ??
          '',
      date: _asDate(
        json['booking_date'] ??
            json['date'] ??
            json['scheduled_date'] ??
            json['start_at'] ??
            json['starts_at'],
      ),
      startTime:
          _asString(
            json['start_time'] ??
                json['slot_start_time'] ??
                slot['start_time'] ??
                slot['from'],
          ) ??
          '',
      endTime:
          _asString(
            json['end_time'] ??
                json['slot_end_time'] ??
                slot['end_time'] ??
                slot['to'],
          ) ??
          '',
      status: BookingStatus.fromString(
        _asString(json['status'] ?? json['booking_status']),
      ),
      amount:
          _asDouble(
            json['total_amount'] ??
                json['booking_total'] ??
                json['final_amount'] ??
                json['amount'] ??
                json['price'] ??
                totals['booking_total'] ??
                totals['total_amount'] ??
                totals['amount'],
          ) ??
          0.0,
      venueId: _asInt(json['venue_id'] ?? venue['id']),
      courtId: _asInt(json['court_id'] ?? court['id']),
      vendorId: _asInt(
        json['vendor_id'] ??
            json['owner_id'] ??
            venue['vendor_id'] ??
            venue['owner_id'] ??
            venue['user_id'] ??
            vendor['id'] ??
            vendor['vendor_id'] ??
            vendor['user_id'],
      ),
      playerId: _asInt(
        // In the booking-details response, top-level `user_id` is the customer
        // who placed the booking. It must never be treated as `vendor_id`;
        // doing so can falsely report that a customer is chatting with themself.
        json['user_id'] ??
            json['player_id'] ??
            json['customer_id'] ??
            json['candidate_user_id'] ??
            json['candidate_id'] ??
            json['booked_by_user_id'] ??
            json['created_by_id'] ??
            json['booked_by'] ??
            player['user_id'] ??
            player['id'],
      ),
      playerName: _asString(
        json['player_name'] ??
            json['customer_name'] ??
            json['booked_by_name'] ??
            player['name'] ??
            player['full_name'] ??
            player['team_name'],
      ),
      playerPhone: _asString(
        json['player_phone'] ??
            json['customer_phone'] ??
            player['phone'] ??
            player['phone_number'] ??
            player['mobile'],
      ),
      playerEmail: _asString(
        json['player_email'] ??
            json['customer_email'] ??
            player['email'] ??
            player['email_address'],
      ),
      futsalAddress: _asString(
        json['futsal_address'] ??
            json['venue_address'] ??
            venue['address'] ??
            venue['exact_location'],
      ),
      bookingType: _asString(json['booking_type']),
      seriesParentId: _asInt(json['series_parent_id']),
      isRecurring: _asBool(json['is_recurring']),
      isSeriesAnchor: _asBool(json['is_series_anchor']),
      recurrenceType: _asString(json['recurrence_type']),
      recurrenceStartDate: _asNullableDate(json['recurrence_start_date']),
      recurrenceEndDate: _asNullableDate(json['recurrence_end_date']),
      slotCount:
          _asInt(json['slot_count']) ??
          (bookingSlots.isEmpty ? 1 : bookingSlots.length),
      pricePerSlot: _asDouble(json['price_per_slot']) ?? 0,
      subtotal: _asDouble(json['subtotal']) ?? 0,
      discountAmount: _asDouble(json['discount_amount']) ?? 0,
      completionDiscount: _asDouble(json['completion_discount']) ?? 0,
      taxAmount: _asDouble(json['tax_amount']) ?? 0,
      extraAmount: _asDouble(json['extra_amount']) ?? 0,
      advanceAmount: _asDouble(json['advance_amount']) ?? 0,
      partialAmount: _asDouble(json['partial_amount']) ?? 0,
      payableNow: _asDouble(json['payable_now']) ?? 0,
      balanceDueLater: _asDouble(json['balance_due_later']) ?? 0,
      paidAmount: _asDouble(json['paid_amount']) ?? 0,
      balanceDue: _asDouble(json['balance_due']) ?? 0,
      paymentStatus: _asString(json['payment_status']),
      notes: _asString(json['notes']),
      coupon: coupon.isEmpty ? null : BookingCouponModel.fromJson(coupon),
      payments: payments.isNotEmpty
          ? payments
          : (singlePayment.isEmpty
                ? const <BookingPaymentModel>[]
                : <BookingPaymentModel>[
                    BookingPaymentModel.fromJson(singlePayment),
                  ]),
      bookingSlots: bookingSlots,
      extraItems: extraItems,
      createdAt: _asNullableDate(json['created_at'] ?? json['booked_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_ref': bookingRef,
    'court_name': courtName,
    'futsal_name': futsalName,
    'date': date.toIso8601String(),
    'start_time': startTime,
    'end_time': endTime,
    'status': status.value,
    'amount': amount,
    'venue_id': venueId,
    'court_id': courtId,
    'vendor_id': vendorId,
    'user_id': playerId,
    'player_id': playerId,
    'player_name': playerName,
    'player_phone': playerPhone,
    'player_email': playerEmail,
    'futsal_address': futsalAddress,
    'booking_type': bookingType,
    'series_parent_id': seriesParentId,
    'is_recurring': isRecurring,
    'is_series_anchor': isSeriesAnchor,
    'recurrence_type': recurrenceType,
    'recurrence_start_date': recurrenceStartDate?.toIso8601String(),
    'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
    'slot_count': slotCount,
    'price_per_slot': pricePerSlot,
    'subtotal': subtotal,
    'discount_amount': discountAmount,
    'completion_discount': completionDiscount,
    'tax_amount': taxAmount,
    'extra_amount': extraAmount,
    'advance_amount': advanceAmount,
    'partial_amount': partialAmount,
    'payable_now': payableNow,
    'balance_due_later': balanceDueLater,
    'paid_amount': paidAmount,
    'balance_due': balanceDue,
    'payment_status': paymentStatus,
    'notes': notes,
    'coupon': coupon?.toJson(),
    'payments': payments
        .map((BookingPaymentModel payment) => payment.toJson())
        .toList(growable: false),
    'booking_slots': bookingSlots
        .map((BookingSlotModel slot) => slot.toJson())
        .toList(growable: false),
    'extra_items': extraItems
        .map((BookingExtraItemModel item) => item.toJson())
        .toList(growable: false),
    'created_at': createdAt?.toIso8601String(),
  };

  static List<BookingModel> listFromResponse(dynamic payload) {
    final List<dynamic> items = _bookingListFrom(payload);
    return items
        .whereType<Map>()
        .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  static BookingModel fromResponse(dynamic payload) {
    final List<BookingModel> bookings = listFromResponse(payload);
    if (bookings.isEmpty) {
      throw const FormatException(
        'Booking detail response does not contain a booking.',
      );
    }
    return bookings.first;
  }

  @override
  List<Object?> get props => [
    id,
    bookingRef,
    courtName,
    futsalName,
    date,
    startTime,
    endTime,
    status,
    amount,
    venueId,
    courtId,
    vendorId,
    playerId,
    playerName,
    playerPhone,
    playerEmail,
    futsalAddress,
    bookingType,
    seriesParentId,
    isRecurring,
    isSeriesAnchor,
    recurrenceType,
    recurrenceStartDate,
    recurrenceEndDate,
    slotCount,
    pricePerSlot,
    subtotal,
    discountAmount,
    completionDiscount,
    taxAmount,
    extraAmount,
    advanceAmount,
    partialAmount,
    payableNow,
    balanceDueLater,
    paidAmount,
    balanceDue,
    paymentStatus,
    notes,
    coupon,
    payments,
    bookingSlots,
    extraItems,
    createdAt,
  ];
}

final class BookingCouponModel extends Equatable {
  const BookingCouponModel({required this.id, this.code, this.title});

  final int id;
  final String? code;
  final String? title;

  factory BookingCouponModel.fromJson(Map<String, dynamic> json) {
    return BookingCouponModel(
      id: _asInt(json['id']) ?? 0,
      code: _asString(json['code']),
      title: _asString(json['title']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'code': code,
    'title': title,
  };

  @override
  List<Object?> get props => <Object?>[id, code, title];
}

final class BookingPaymentModel extends Equatable {
  const BookingPaymentModel({
    required this.id,
    this.method,
    this.type,
    this.amount = 0,
    this.status,
    this.verificationStatus,
    this.paymentProofPath,
    this.paymentProofUrl,
    this.hasPaymentProof = false,
    this.note,
    this.createdAt,
  });

  final int id;
  final String? method;

  /// The API's `payment_type`, which mirrors `payment_method` today but is sent
  /// separately (e.g. `cash`, `online`).
  final String? type;
  final double amount;
  final String? status;
  final String? verificationStatus;
  final String? paymentProofPath;
  final String? paymentProofUrl;
  final bool hasPaymentProof;
  final String? note;

  /// When the payment was recorded, per the API's `created_at`.
  final DateTime? createdAt;

  BookingPaymentModel copyWith({
    int? id,
    String? method,
    String? type,
    double? amount,
    String? status,
    String? verificationStatus,
    String? paymentProofPath,
    String? paymentProofUrl,
    bool? hasPaymentProof,
    String? note,
    DateTime? createdAt,
  }) {
    return BookingPaymentModel(
      id: id ?? this.id,
      method: method ?? this.method,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      paymentProofPath: paymentProofPath ?? this.paymentProofPath,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      hasPaymentProof: hasPaymentProof ?? this.hasPaymentProof,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BookingPaymentModel.fromJson(Map<String, dynamic> json) {
    return BookingPaymentModel(
      id: _asInt(json['id']) ?? 0,
      method: _asString(json['payment_method']),
      type: _asString(json['payment_type']),
      amount: _asDouble(json['amount']) ?? 0,
      status: _asString(json['status']),
      verificationStatus: _asString(json['verification_status']),
      paymentProofPath: _asString(json['payment_proof']),
      paymentProofUrl: _asString(json['payment_proof_url']),
      hasPaymentProof: _asBool(json['has_payment_proof']),
      note: _asString(json['payment_note']),
      createdAt: _asNullableDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'payment_method': method,
    'payment_type': type,
    'amount': amount,
    'status': status,
    'verification_status': verificationStatus,
    'payment_proof': paymentProofPath,
    'payment_proof_url': paymentProofUrl,
    'has_payment_proof': hasPaymentProof,
    'payment_note': note,
    'created_at': createdAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => <Object?>[
    id,
    method,
    type,
    amount,
    status,
    verificationStatus,
    paymentProofPath,
    paymentProofUrl,
    hasPaymentProof,
    note,
    createdAt,
  ];
}

final class BookingSlotModel extends Equatable {
  const BookingSlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.price = 0,
    this.status,
  });

  final int id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final String? status;

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      id: _asInt(json['id']) ?? 0,
      date: _asDate(json['slot_date']),
      startTime: _asString(json['slot_start']) ?? '',
      endTime: _asString(json['slot_end']) ?? '',
      price: _asDouble(json['slot_price']) ?? 0,
      status: _asString(json['status']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'slot_date': date.toIso8601String(),
    'slot_start': startTime,
    'slot_end': endTime,
    'slot_price': price,
    'status': status,
  };

  @override
  List<Object?> get props => <Object?>[
    id,
    date,
    startTime,
    endTime,
    price,
    status,
  ];
}

final class BookingExtraItemModel extends Equatable {
  const BookingExtraItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    this.unitPrice = 0,
    this.totalAmount = 0,
    this.productPrice,
    this.productIsActive = true,
  });

  final int id;
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalAmount;

  /// The product's current catalogue price, which can differ from [unitPrice]
  /// when the price changed after the booking was made.
  final double? productPrice;

  /// Whether the underlying product is still sellable. Archived products stay
  /// on the booking but should not be offered again.
  final bool productIsActive;

  factory BookingExtraItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> product = _mapOf(json['product']);
    final int quantity = _asInt(json['quantity'] ?? json['qty']) ?? 0;
    final double unitPrice =
        _asDouble(
          json['unit_price'] ??
              json['price_per_unit'] ??
              json['price'] ??
              product['price'],
        ) ??
        0;
    return BookingExtraItemModel(
      id: _asInt(json['id']) ?? 0,
      productId:
          _asInt(
            json['product_id'] ?? json['venue_product_id'] ?? product['id'],
          ) ??
          0,
      name:
          _asString(
            json['name'] ??
                json['product_name'] ??
                json['title'] ??
                product['name'] ??
                product['title'],
          ) ??
          '',
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount:
          _asDouble(
            json['total_amount'] ??
                json['total_price'] ??
                json['line_total'] ??
                json['subtotal'],
          ) ??
          (unitPrice * quantity),
      productPrice: _asDouble(product['price']),
      productIsActive: product.containsKey('is_active')
          ? _asBool(product['is_active'])
          : true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'product_id': productId,
    'name': name,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total_amount': totalAmount,
    'product': <String, dynamic>{
      'id': productId,
      'name': name,
      'price': productPrice ?? unitPrice,
      'is_active': productIsActive,
    },
  };

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    name,
    quantity,
    unitPrice,
    totalAmount,
    productPrice,
    productIsActive,
  ];
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  rejected('rejected'),
  completed('completed');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'confirmed' ||
      'approved' ||
      'accepted' ||
      'paid' => BookingStatus.confirmed,
      'rejected' || 'declined' => BookingStatus.rejected,
      'cancelled' || 'canceled' => BookingStatus.cancelled,
      'completed' || 'complete' || 'finished' => BookingStatus.completed,
      _ => BookingStatus.pending,
    };
  }
}

List<dynamic> _bookingListFrom(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is List) return current;
    if (current is! Map) return const <dynamic>[];

    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic next =
        map['data'] ??
        map['booking'] ??
        map['bookings'] ??
        map['futsal_bookings'] ??
        map['items'] ??
        map['records'] ??
        map['results'];

    if (next == null) {
      return _looksLikeBooking(map) ? <dynamic>[map] : const <dynamic>[];
    }
    current = next;
  }
  return const <dynamic>[];
}

bool _looksLikeBooking(Map<String, dynamic> map) {
  return map.containsKey('booking_id') ||
      map.containsKey('booking_ref') ||
      map.containsKey('booking_date') ||
      (map.containsKey('id') &&
          (map.containsKey('court') || map.containsKey('court_id')));
}

Map<String, dynamic> _mapOf(dynamic value) {
  return value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((Map item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

String? _asString(Object? value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime _asDate(Object? value) {
  if (value is DateTime) return value;
  final String text = value?.toString().trim() ?? '';
  return DateTime.tryParse(text) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _asNullableDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim());
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' || 'yes' => true,
    _ => false,
  };
}

String _displayTime(String value) {
  final List<String> parts = value.trim().split(':');
  if (parts.length < 2) return value.trim();
  final int? hour = int.tryParse(parts[0]);
  final int? minute = int.tryParse(parts[1]);
  if (hour == null || minute == null || hour > 23 || minute > 59) {
    return value.trim();
  }
  final String period = hour >= 12 ? 'PM' : 'AM';
  final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

/// Floors a money figure at zero. Deliberately not `clamp`, because `num.clamp`
/// hands back the limit itself — the `int` literal `0` — which then fails the
/// `double` return-type check of the getters below.
double _atLeastZero(double value) {
  if (value.isNaN) return 0;
  return value < 0 ? 0 : value;
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

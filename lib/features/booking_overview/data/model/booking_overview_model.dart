enum BookingStatus { completed, confirmed, pending, cancelled }

extension BookingStatusLabel on BookingStatus {
  String get label => switch (this) {
    BookingStatus.completed => 'Completed',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.pending => 'Pending',
    BookingStatus.cancelled => 'Cancelled',
  };
}

class BookingCourtModel {
  const BookingCourtModel({
    required this.id,
    required this.futsalId,
    required this.name,
    required this.hourlyRate,
  });

  final String id;
  final String futsalId;
  final String name;
  final int hourlyRate;

  factory BookingCourtModel.fromJson(Map<String, dynamic> json) =>
      BookingCourtModel(
        id: json['id']?.toString() ?? '',
        futsalId: json['futsal_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        hourlyRate: json['hourly_rate'] is int
            ? json['hourly_rate'] as int
            : int.tryParse(json['hourly_rate']?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'futsal_id': futsalId,
    'name': name,
    'hourly_rate': hourlyRate,
  };
}

class BookingFutsalModel {
  const BookingFutsalModel({
    required this.id,
    required this.name,
    required this.area,
    required this.monthlyOverhead,
    required this.courts,
  });

  final String id;
  final String name;
  final String area;
  final int monthlyOverhead;
  final List<BookingCourtModel> courts;

  factory BookingFutsalModel.fromJson(Map<String, dynamic> json) =>
      BookingFutsalModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        area: json['area']?.toString() ?? '',
        monthlyOverhead: json['monthly_overhead'] is int
            ? json['monthly_overhead'] as int
            : int.tryParse(json['monthly_overhead']?.toString() ?? '') ?? 0,
        courts: (json['courts'] as List<dynamic>? ?? const [])
            .map((c) => BookingCourtModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'area': area,
    'monthly_overhead': monthlyOverhead,
    'courts': courts.map((c) => c.toJson()).toList(),
  };
}

class BookingRecordModel {
  const BookingRecordModel({
    required this.id,
    required this.futsalId,
    required this.courtId,
    required this.start,
    required this.hours,
    required this.amount,
    required this.status,
    required this.customer,
  });

  final String id;
  final String futsalId;
  final String courtId;
  final DateTime start;
  final int hours;
  final int amount;
  final BookingStatus status;
  final String customer;

  factory BookingRecordModel.fromJson(
    Map<String, dynamic> json,
  ) => BookingRecordModel(
    id: json['id']?.toString() ?? '',
    futsalId: json['futsal_id']?.toString() ?? '',
    courtId: json['court_id']?.toString() ?? '',
    start: DateTime.tryParse(json['start']?.toString() ?? '') ?? DateTime.now(),
    hours: json['hours'] is int
        ? json['hours'] as int
        : int.tryParse(json['hours']?.toString() ?? '') ?? 1,
    amount: json['amount'] is int
        ? json['amount'] as int
        : int.tryParse(json['amount']?.toString() ?? '') ?? 0,
    status:
        BookingStatus.values.asNameMap()[json['status']] ??
        BookingStatus.pending,
    customer: json['customer']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'futsal_id': futsalId,
    'court_id': courtId,
    'start': start.toIso8601String(),
    'hours': hours,
    'amount': amount,
    'status': status.name,
    'customer': customer,
  };
}

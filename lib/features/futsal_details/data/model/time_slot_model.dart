enum SlotStatus {
  available,
  unavailable,
  booked,
  closed;

  static SlotStatus fromApi(dynamic value) {
    final String normalized =
        value?.toString().trim().toLowerCase().replaceAll(
          RegExp(r'[\s-]+'),
          '_',
        ) ??
        '';
    return switch (normalized) {
      'available' => SlotStatus.available,
      'booked' || 'reserved' || 'fully_booked' => SlotStatus.booked,
      'closed' => SlotStatus.closed,
      'unavailable' || 'blocked' => SlotStatus.unavailable,
      _ => SlotStatus.unavailable,
    };
  }

  String get apiValue => name;

  String get label {
    return switch (this) {
      SlotStatus.available => 'Available',
      SlotStatus.unavailable => 'Unavailable',
      SlotStatus.booked => 'Booked',
      SlotStatus.closed => 'Closed',
    };
  }

  bool get canSelect => this == SlotStatus.available;
}

class TimeSlotModel {
  final String time;
  final String? apiTime;
  final String? endTime;
  final String? apiEndTime;
  final bool isSelected;
  final String? price;
  final int? id;
  final int? totalCourts;
  final int? availableCourts;
  final int? bookedCourts;
  final SlotStatus status;

  const TimeSlotModel({
    required this.time,
    this.apiTime,
    this.endTime,
    this.apiEndTime,
    this.isSelected = false,
    this.price,
    this.id,
    this.totalCourts,
    this.availableCourts,
    this.bookedCourts,
    this.status = SlotStatus.available,
  });

  bool get isAvailable => status.canSelect;
  bool get isBooked => status == SlotStatus.booked;
  bool get isUnavailable => status == SlotStatus.unavailable;
  bool get isClosed => status == SlotStatus.closed;
}

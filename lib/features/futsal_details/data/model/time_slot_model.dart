class TimeSlotModel {
  final String time;
  final String? apiTime;
  final String? endTime;
  final String? apiEndTime;
  final bool isAvailable;
  final bool isSelected;
  final String? price;
  final int? id;
  final int? totalCourts;
  final int? availableCourts;
  final int? bookedCourts;
  final String? status;
  final bool isBooked;
  final bool isUnavailable;
  final bool isFullyBooked;

  const TimeSlotModel({
    required this.time,
    this.apiTime,
    this.endTime,
    this.apiEndTime,
    this.isAvailable = true,
    this.isSelected = false,
    this.price,
    this.id,
    this.totalCourts,
    this.availableCourts,
    this.bookedCourts,
    this.status,
    this.isBooked = false,
    this.isUnavailable = false,
    this.isFullyBooked = false,
  });
}

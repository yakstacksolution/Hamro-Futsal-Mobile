class TimeSlotModel {
  final String time;
  final bool isAvailable;
  final bool isSelected;
  final String? price;

  const TimeSlotModel({
    required this.time,
    this.isAvailable = true,
    this.isSelected = false,
    this.price,
  });
}

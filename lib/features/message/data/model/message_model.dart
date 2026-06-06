enum MessageFilter { all, unread, active, bookings }

extension MessageFilterX on MessageFilter {
  String get label => switch (this) {
    MessageFilter.all => 'All',
    MessageFilter.unread => 'Unread',
    MessageFilter.active => 'Active',
    MessageFilter.bookings => 'Bookings',
  };
}

class MessageModel {
  const MessageModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isActive = false,
    this.isBooking = false,
  });

  final String id;
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isActive;
  final bool isBooking;

  bool get isUnread => unreadCount > 0;

  MessageModel copyWith({int? unreadCount}) => MessageModel(
    id: id,
    name: name,
    message: message,
    time: time,
    avatarUrl: avatarUrl,
    unreadCount: unreadCount ?? this.unreadCount,
    isActive: isActive,
    isBooking: isBooking,
  );
}

import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/message_model.dart';

abstract class MessageDataSource {
  Future<List<MessageModel>> fetchMessages();
  Future<List<ChatMessageModel>> fetchChat(MessageModel conversation);
}

/// Local demo data source.
///
/// Swap this with an API-backed implementation once the messaging backend
/// exists — the page and widgets above it stay untouched.
final class MessageLocalDataSourceImpl implements MessageDataSource {
  @override
  Future<List<MessageModel>> fetchMessages() async => const [
    MessageModel(
      id: 'm1',
      name: 'Andy Robertson',
      message: 'Oh yes, please send your booking details.',
      time: '5m',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      unreadCount: 2,
      isActive: true,
      isBooking: true,
    ),
    MessageModel(
      id: 'm2',
      name: 'Giorgio Chiellini',
      message: 'Hello sir, good morning.',
      time: '30m',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      isActive: true,
    ),
    MessageModel(
      id: 'm3',
      name: 'Alex Morgan',
      message: 'I saw the futsal slot you posted yesterday.',
      time: '09:30',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      isBooking: true,
    ),
    MessageModel(
      id: 'm4',
      name: 'Ilkay Gundogan',
      message: 'Can we reschedule tonight’s booking?',
      time: 'Yesterday',
      avatarUrl: 'https://i.pravatar.cc/150?img=51',
      isBooking: true,
    ),
    MessageModel(
      id: 'm5',
      name: 'Megan Rapinoe',
      message: 'Thanks, I will confirm the team shortly.',
      time: '13:00',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    MessageModel(
      id: 'm6',
      name: 'Alessandro Bastoni',
      message: 'Please share the location pin once again.',
      time: '18:00',
      avatarUrl: 'https://i.pravatar.cc/150?img=58',
      unreadCount: 1,
    ),
  ];

  @override
  Future<List<ChatMessageModel>> fetchChat(MessageModel conversation) async {
    // Demo thread ending with the conversation's latest preview message.
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    DateTime at(DateTime d, int h, int m) =>
        DateTime(d.year, d.month, d.day, h, m);

    return [
      ChatMessageModel(
        id: 'c1',
        text: 'Hi! Is the 7 PM slot still available tomorrow?',
        sentAt: at(yesterday, 18, 42),
        isMe: true,
        seen: true,
      ),
      ChatMessageModel(
        id: 'c2',
        text: 'Hello! Yes, the 7–8 PM slot is open.',
        sentAt: at(yesterday, 18, 50),
        isMe: false,
      ),
      ChatMessageModel(
        id: 'c3',
        text: 'Great — we are 10 players, planning a 5v5.',
        sentAt: at(yesterday, 18, 55),
        isMe: true,
        seen: true,
      ),
      ChatMessageModel(
        id: 'c4',
        text: 'Perfect, I can hold the court for you.',
        sentAt: at(yesterday, 19, 2),
        isMe: false,
      ),
      ChatMessageModel(
        id: 'c5',
        text: 'Booked it from the app just now. See you!',
        sentAt: now.subtract(const Duration(hours: 2)),
        isMe: true,
        seen: true,
      ),
      ChatMessageModel(
        id: 'c6',
        text: conversation.message,
        sentAt: now.subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    ];
  }
}

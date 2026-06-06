import 'package:hamro_footsall/features/message/data/model/message_model.dart';

abstract class MessageDataSource {
  Future<List<MessageModel>> fetchMessages();
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
}

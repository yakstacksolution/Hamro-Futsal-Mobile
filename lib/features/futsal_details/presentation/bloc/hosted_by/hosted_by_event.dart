part of 'hosted_by_bloc.dart';

sealed class HostedByEvent extends Equatable {
  const HostedByEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchHostedByEvent extends HostedByEvent {
  const FetchHostedByEvent({required this.venueId});

  final int venueId;

  @override
  List<Object?> get props => <Object?>[venueId];
}

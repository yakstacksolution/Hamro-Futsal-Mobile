part of 'public_templates_bloc.dart';

sealed class PublicTemplatesEvent extends Equatable {
  const PublicTemplatesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchPublicTemplatesEvent extends PublicTemplatesEvent {
  const FetchPublicTemplatesEvent();
}

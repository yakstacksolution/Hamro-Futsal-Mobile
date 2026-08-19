part of 'public_templates_bloc.dart';

enum PublicTemplatesStatus { idle, loading, success, failure }

final class PublicTemplatesState extends Equatable {
  const PublicTemplatesState({
    this.status = PublicTemplatesStatus.idle,
    this.templates = const <PublicTemplateModel>[],
    this.errorMessage,
  });

  final PublicTemplatesStatus status;
  final List<PublicTemplateModel> templates;
  final String? errorMessage;

  PublicTemplatesState copyWith({
    PublicTemplatesStatus? status,
    List<PublicTemplateModel>? templates,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublicTemplatesState(
      status: status ?? this.status,
      templates: templates ?? this.templates,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, templates, errorMessage];
}

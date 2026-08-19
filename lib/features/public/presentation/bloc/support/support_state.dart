part of 'support_bloc.dart';

enum SupportStatus { initial, loading, success, failure }

final class SupportState extends Equatable {
  const SupportState({
    this.faqsStatus = SupportStatus.initial,
    this.helpsStatus = SupportStatus.initial,
    this.faqs = const <PublicFaqModel>[],
    this.helps = const <PublicHelpModel>[],
    this.faqsError,
    this.helpsError,
  });

  final SupportStatus faqsStatus;
  final SupportStatus helpsStatus;
  final List<PublicFaqModel> faqs;
  final List<PublicHelpModel> helps;
  final String? faqsError;
  final String? helpsError;

  SupportState copyWith({
    SupportStatus? faqsStatus,
    SupportStatus? helpsStatus,
    List<PublicFaqModel>? faqs,
    List<PublicHelpModel>? helps,
    String? faqsError,
    String? helpsError,
  }) {
    return SupportState(
      faqsStatus: faqsStatus ?? this.faqsStatus,
      helpsStatus: helpsStatus ?? this.helpsStatus,
      faqs: faqs ?? this.faqs,
      helps: helps ?? this.helps,
      faqsError: faqsError ?? this.faqsError,
      helpsError: helpsError ?? this.helpsError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    faqsStatus,
    helpsStatus,
    faqs,
    helps,
    faqsError,
    helpsError,
  ];
}

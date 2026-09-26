part of 'support_bloc.dart';

enum SupportStatus { initial, loading, success, failure }

final class SupportState extends Equatable {
  const SupportState({
    this.faqsStatus = SupportStatus.initial,
    this.helpsStatus = SupportStatus.initial,
    this.videosStatus = SupportStatus.initial,
    this.faqs = const <PublicFaqModel>[],
    this.helps = const <PublicHelpModel>[],
    this.videos = const <HelpVideo>[],
    this.faqsError,
    this.helpsError,
    this.videosError,
  });

  final SupportStatus faqsStatus;
  final SupportStatus helpsStatus;
  final SupportStatus videosStatus;
  final List<PublicFaqModel> faqs;
  final List<PublicHelpModel> helps;
  final List<HelpVideo> videos;
  final String? faqsError;
  final String? helpsError;
  final String? videosError;

  SupportState copyWith({
    SupportStatus? faqsStatus,
    SupportStatus? helpsStatus,
    SupportStatus? videosStatus,
    List<PublicFaqModel>? faqs,
    List<PublicHelpModel>? helps,
    List<HelpVideo>? videos,
    String? faqsError,
    String? helpsError,
    String? videosError,
  }) {
    return SupportState(
      faqsStatus: faqsStatus ?? this.faqsStatus,
      helpsStatus: helpsStatus ?? this.helpsStatus,
      videosStatus: videosStatus ?? this.videosStatus,
      faqs: faqs ?? this.faqs,
      helps: helps ?? this.helps,
      videos: videos ?? this.videos,
      faqsError: faqsError ?? this.faqsError,
      helpsError: helpsError ?? this.helpsError,
      videosError: videosError ?? this.videosError,
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
    videosStatus,
    videos,
    videosError,
  ];
}

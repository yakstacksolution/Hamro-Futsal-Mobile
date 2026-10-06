part of 'booking_overview_bloc.dart';

enum BookingOverviewStatus { initial, loading, success, failure }

enum BookingExportStatus { idle, exporting, success, failure }

final class BookingOverviewState extends Equatable {
  const BookingOverviewState({
    this.status = BookingOverviewStatus.initial,
    this.overview,
    this.errorMessage,
    this.exportStatus = BookingExportStatus.idle,
    this.exportFile,
    this.exportErrorMessage,
  });

  final BookingOverviewStatus status;
  final BookingOverviewResponse? overview;
  final String? errorMessage;

  final BookingExportStatus exportStatus;

  final BookingExportFile? exportFile;
  final String? exportErrorMessage;

  BookingOverviewState copyWith({
    BookingOverviewStatus? status,
    BookingOverviewResponse? overview,
    String? errorMessage,
    bool clearErrorMessage = false,
    BookingExportStatus? exportStatus,
    BookingExportFile? exportFile,
    bool clearExportFile = false,
    String? exportErrorMessage,
    bool clearExportErrorMessage = false,
  }) {
    return BookingOverviewState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      exportStatus: exportStatus ?? this.exportStatus,
      exportFile: clearExportFile ? null : exportFile ?? this.exportFile,
      exportErrorMessage: clearExportErrorMessage
          ? null
          : exportErrorMessage ?? this.exportErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    errorMessage,
    exportStatus,
    exportFile,
    exportErrorMessage,
  ];
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/booking_overview/data/data_source/booking_overview_data_source.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/domain/model/booking_export_file.dart';
import 'package:hamro_futsal/features/booking_overview/domain/repository/booking_overview_repository.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

final class BookingOverviewRepositoryImpl extends BookingOverviewRepository {
  BookingOverviewRepositoryImpl({BookingOverviewDataSource? dataSource})
    : _dataSource = dataSource ?? BookingOverviewRemoteDataSourceImpl();

  final BookingOverviewDataSource _dataSource;

  @override
  Future<Either<AppException, BookingOverviewResponse>> getOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    final response = await _dataSource.fetchBookingOverview(
      dateFilter: dateFilter,
      dateFrom: dateFrom,
      dateTo: dateTo,
      venueIds: venueIds,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingOverviewResponse.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadBookings,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, BookingExportFile>> exportBookingsOverView({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    final response = await _dataSource.exportBookingsOverView(
      dateFilter: dateFilter,
      dateFrom: dateFrom,
      dateTo: dateTo,
      venueIds: venueIds,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    final String stem = exportFileStem(
      dateFilter: dateFilter,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    final BookingExportFile? file = parseExport(response.getValue(), stem);
    return file == null
        ? left(
            DefaultException(
              errorMessage: StringConstants.couldNotExportBookings,
              statusCode: 0,
            ),
          )
        : right(file);
  }

  static String exportFileStem({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    DateTime? now,
  }) {
    final DateTime at = now ?? DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final String stamp =
        '${at.year}${two(at.month)}${two(at.day)}_${two(at.hour)}${two(at.minute)}';
    final String window =
        (dateFrom?.isNotEmpty ?? false) && (dateTo?.isNotEmpty ?? false)
        ? '${dateFrom}_to_$dateTo'
        : (dateFilter?.isNotEmpty ?? false)
        ? dateFilter!
        : 'all';
    return 'bookings_${window}_$stamp';
  }

  static BookingExportFile? parseExport(dynamic body, String stem) {
    final Uint8List bytes = switch (body) {
      final Uint8List data => data,
      final List<int> data => Uint8List.fromList(data),
      final String text => Uint8List.fromList(utf8.encode(text)),
      _ => Uint8List(0),
    };
    if (bytes.isEmpty) return null;
    return BookingExportFile(bytes: bytes, fileName: '$stem.csv');
  }
}

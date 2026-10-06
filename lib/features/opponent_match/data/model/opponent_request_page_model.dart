import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_summary_model.dart';

class OpponentRequestPageModel {
  const OpponentRequestPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.summary,
  });

  final List<OpponentRequestModel> items;
  final int currentPage;
  final int lastPage;

  final int total;
  final bool hasMore;

  final OpponentRequestSummaryModel? summary;

  factory OpponentRequestPageModel.single(
    List<OpponentRequestModel> items, {
    OpponentRequestSummaryModel? summary,
  }) => OpponentRequestPageModel(
    items: items,
    currentPage: 1,
    lastPage: 1,
    total: items.length,
    hasMore: false,
    summary: summary,
  );

  factory OpponentRequestPageModel.fromJson(
    Map<String, dynamic> pagination,
    List<OpponentRequestModel> items, {
    OpponentRequestSummaryModel? summary,
  }) {
    int intOf(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
    }

    final int current = intOf(pagination['current_page'], 1);
    final int last = intOf(pagination['last_page'], current);
    final bool hasMore = pagination['has_more_pages'] is bool
        ? pagination['has_more_pages'] as bool
        : current < last;
    return OpponentRequestPageModel(
      items: items,
      currentPage: current,
      lastPage: last,
      total: intOf(pagination['total'], items.length),
      hasMore: hasMore,
      summary: summary,
    );
  }
}

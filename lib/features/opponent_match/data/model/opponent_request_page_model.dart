import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_summary_model.dart';

/// One page of `/auth/opponent-requests?tab=…&page=N&per_page=M`, with the
/// `pagination` block the endpoint sends beside the rows.
///
/// The rows alone cannot say whether more exist: a short page can mean the end
/// of the list or simply a page that the server trimmed. `hasMore` is the
/// server's own answer, so the list stops asking exactly when it should.
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

  /// Rows across every page, which is what the tab's count chip shows once the
  /// first page has landed.
  final int total;
  final bool hasMore;

  /// Every tab's count as the server reported it beside this page, or null for
  /// a payload that carried no `summary` block.
  final OpponentRequestSummaryModel? summary;

  /// A page for a payload that carried no `pagination` block: whatever rows
  /// came back, treated as the whole list.
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

  /// Reads the block the endpoint sends. `has_more_pages` is trusted when
  /// present; otherwise the page numbers answer the same question.
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

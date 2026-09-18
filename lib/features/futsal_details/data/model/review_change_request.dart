/// What the reviewer is asking the venue's admin to do with their own review.
///
/// `POST /reviews/{review}/change-request` takes `request_type` plus a free
/// text `reason`; the type travels as the value of [apiValue].
enum ReviewChangeRequestType {
  edit('edit'),
  delete('delete');

  const ReviewChangeRequestType(this.apiValue);

  /// The `request_type` the API expects.
  final String apiValue;
}

/// One `/reviews/{review}/change-request` submission.
///
/// An edit carries the review the user wants in place of the current one —
/// the server rejects the request without it ("The requested review field is
/// required when request type is edit") — while a delete carries only the
/// reason.
class ReviewChangeRequestInput {
  const ReviewChangeRequestInput({
    required this.type,
    required this.reason,
    this.requestedReview = '',
  });

  final ReviewChangeRequestType type;
  final String reason;

  /// The wording that should stand in place of the current comment. Required
  /// for [ReviewChangeRequestType.edit]. The rating is never touched — only
  /// the text of an abusive review is at issue.
  final String requestedReview;

  bool get isEdit => type == ReviewChangeRequestType.edit;

  /// The request body. The edit-only fields are left out of a delete so the
  /// payload carries nothing the server did not ask for.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'request_type': type.apiValue,
      'reason': reason,
      if (isEdit) 'requested_review': requestedReview,
    };
  }
}

enum ReviewChangeRequestType {
  edit('edit'),
  delete('delete');

  const ReviewChangeRequestType(this.apiValue);

  final String apiValue;
}

class ReviewChangeRequestInput {
  const ReviewChangeRequestInput({
    required this.type,
    required this.reason,
    this.requestedReview = '',
  });

  final ReviewChangeRequestType type;
  final String reason;

  final String requestedReview;

  bool get isEdit => type == ReviewChangeRequestType.edit;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'request_type': type.apiValue,
      'reason': reason,
      if (isEdit) 'requested_review': requestedReview,
    };
  }
}

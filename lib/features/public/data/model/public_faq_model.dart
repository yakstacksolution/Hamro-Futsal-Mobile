import 'package:equatable/equatable.dart';

/// A frequently-asked question from `GET /faqs`.
final class PublicFaqModel extends Equatable {
  const PublicFaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.raw,
  });

  final String id;
  final String question;
  final String answer;
  final Map<String, dynamic> raw;

  factory PublicFaqModel.fromJson(Map<String, dynamic> json) {
    return PublicFaqModel(
      id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
      question: (json['question'] ?? json['title'] ?? '').toString().trim(),
      answer:
          (json['answer'] ??
                  json['description'] ??
                  json['content'] ??
                  json['body'] ??
                  '')
              .toString()
              .trim(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, question, answer, raw];
}

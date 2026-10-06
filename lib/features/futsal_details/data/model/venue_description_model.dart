import 'package:equatable/equatable.dart';

final class VenueDescriptionModel extends Equatable {
  const VenueDescriptionModel({
    this.description = '',
    this.rules = '',
    this.policy = '',
  });

  final String description;

  final String rules;

  final String policy;

  factory VenueDescriptionModel.fromJson(Map<String, dynamic> json) {
    return VenueDescriptionModel(
      description: _parseString(
        json['description'] ?? json['venue_description'],
      ),
      rules: _parseString(json['rules'] ?? json['futsal_rules']),
      policy: _parseString(
        json['policy'] ??
            json['cancellation_policy'] ??
            json['cancelation_policy'],
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'description': description,
    'rules': rules,
    'policy': policy,
  };

  bool get hasData =>
      description.isNotEmpty || rules.isNotEmpty || policy.isNotEmpty;

  static String _parseString(dynamic value) => value?.toString().trim() ?? '';

  @override
  List<Object?> get props => <Object?>[description, rules, policy];
}

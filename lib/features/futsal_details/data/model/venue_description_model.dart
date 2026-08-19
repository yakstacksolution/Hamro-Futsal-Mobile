import 'package:equatable/equatable.dart';

/// Venue texts returned by `/venue-description/{venue_id}`.
///
/// Response shape (all values are HTML):
/// ```json
/// {
///   "description": "<p>...</p>",
///   "rules": "<p>...</p>",
///   "policy": "<p>...</p>"
/// }
/// ```
final class VenueDescriptionModel extends Equatable {
  const VenueDescriptionModel({
    this.description = '',
    this.rules = '',
    this.policy = '',
  });

  /// "About this venue" HTML.
  final String description;

  /// Futsal rules HTML.
  final String rules;

  /// Cancellation policy HTML.
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

  bool get hasData =>
      description.isNotEmpty || rules.isNotEmpty || policy.isNotEmpty;

  static String _parseString(dynamic value) => value?.toString().trim() ?? '';

  @override
  List<Object?> get props => <Object?>[description, rules, policy];
}

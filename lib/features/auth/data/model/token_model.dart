import 'package:equatable/equatable.dart';

class TokenModel extends Equatable {
  final String? tokenType;
  final int? expiredIn;
  final String? accessToken;
  final String? refreshToken;

  const TokenModel({
    this.tokenType,
    this.expiredIn,
    this.accessToken,
    this.refreshToken,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final dynamic expires = json['expires_in'] ?? json['expired_in'];
    return TokenModel(
      tokenType: _string(json['token_type'] ?? json['type']),
      expiredIn: expires is int ? expires : int.tryParse('$expires'),
      accessToken: _string(json['access_token'] ?? json['token']),
      refreshToken: _string(json['refresh_token']),
    );
  }

  bool get hasAccessToken => accessToken?.trim().isNotEmpty == true;

  static String? _string(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Map<String, dynamic> toJson() {
    return {
      'token_type': tokenType,
      'expired_in': expiredIn,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  TokenModel copyWith({
    String? tokenType,
    int? expiredIn,
    String? accessToken,
    String? refreshToken,
  }) {
    return TokenModel(
      tokenType: tokenType ?? this.tokenType,
      expiredIn: expiredIn ?? this.expiredIn,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  List<Object?> get props => [tokenType, expiredIn, accessToken, refreshToken];

  @override
  bool get stringify => true;
}

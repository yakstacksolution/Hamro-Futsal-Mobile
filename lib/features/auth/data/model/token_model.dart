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
    return TokenModel(
      tokenType: json['token_type'] as String?,
      expiredIn: json['expired_in'] as int?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
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
  List<Object?> get props => [
        tokenType,
        expiredIn,
        accessToken,
        refreshToken,
      ];

  @override
  bool get stringify => true;
}
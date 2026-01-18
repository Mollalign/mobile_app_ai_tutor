// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RefreshTokenModel _$RefreshTokenModelFromJson(Map<String, dynamic> json) =>
    _RefreshTokenModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$RefreshTokenModelToJson(_RefreshTokenModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };

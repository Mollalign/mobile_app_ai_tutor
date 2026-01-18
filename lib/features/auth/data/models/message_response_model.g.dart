// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageResponseModel _$MessageResponseModelFromJson(
  Map<String, dynamic> json,
) => _MessageResponseModel(
  message: json['message'] as String,
  success: json['success'] as bool? ?? true,
);

Map<String, dynamic> _$MessageResponseModelToJson(
  _MessageResponseModel instance,
) => <String, dynamic>{
  'message': instance.message,
  'success': instance.success,
};

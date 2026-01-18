import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_response_model.freezed.dart';
part 'message_response_model.g.dart';

/// Simple message response from various endpoints.
/// 
/// Returned from: /auth/forgot-password, /auth/verify-reset-code, /auth/reset-password
@freezed
abstract class MessageResponseModel with _$MessageResponseModel {
  const factory MessageResponseModel({
    required String message,
    @Default(true) bool success,
  }) = _MessageResponseModel;

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) => 
      _$MessageResponseModelFromJson(json);
}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_message.freezed.dart';
part 'contact_message.g.dart';

@freezed
class ContactMessage with _$ContactMessage {
  const factory ContactMessage({
    required String id,
    required String senderUserId,
    required String senderName,
    required String senderEmail,
    required String recipientCompanyId,
    required String recipientCompanyName,
    required String subject,
    required String message,
    String? productId,
    String? productName,
    @Default(false) bool read,
    DateTime? createdAt,
  }) = _ContactMessage;

  factory ContactMessage.fromJson(Map<String, dynamic> json) =>
      _$ContactMessageFromJson(json);
}

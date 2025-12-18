// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactMessageImpl _$$ContactMessageImplFromJson(Map<String, dynamic> json) =>
    _$ContactMessageImpl(
      id: json['id'] as String,
      senderUserId: json['senderUserId'] as String,
      senderName: json['senderName'] as String,
      senderEmail: json['senderEmail'] as String,
      recipientCompanyId: json['recipientCompanyId'] as String,
      recipientCompanyName: json['recipientCompanyName'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ContactMessageImplToJson(
  _$ContactMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderUserId': instance.senderUserId,
  'senderName': instance.senderName,
  'senderEmail': instance.senderEmail,
  'recipientCompanyId': instance.recipientCompanyId,
  'recipientCompanyName': instance.recipientCompanyName,
  'subject': instance.subject,
  'message': instance.message,
  'productId': instance.productId,
  'productName': instance.productName,
  'read': instance.read,
  'createdAt': instance.createdAt?.toIso8601String(),
};

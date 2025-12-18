import 'package:flutter_app/src/features/contact/domain/entities/contact_message.dart';

abstract class ContactRepository {
  /// Envía un mensaje de contacto a una empresa
  Future<void> sendContactMessage(ContactMessage message);

  /// Obtiene los mensajes recibidos por una empresa
  Future<List<ContactMessage>> getReceivedMessages(String companyId);

  /// Marca un mensaje como leído
  Future<void> markAsRead(String messageId);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/src/features/contact/domain/entities/contact_message.dart';
import 'package:flutter_app/src/features/contact/domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final FirebaseFirestore _firestore;

  ContactRepositoryImpl(this._firestore);

  @override
  Future<void> sendContactMessage(ContactMessage message) async {
    try {
      final docRef = _firestore.collection('contact_messages').doc();
      final messageWithId = message.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );
      await docRef.set(messageWithId.toJson());
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  @override
  Future<List<ContactMessage>> getReceivedMessages(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('contact_messages')
          .where('recipientCompanyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ContactMessage.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar mensajes: $e');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await _firestore.collection('contact_messages').doc(messageId).update({
        'read': true,
      });
    } catch (e) {
      throw Exception('Error al marcar mensaje como leído: $e');
    }
  }
}

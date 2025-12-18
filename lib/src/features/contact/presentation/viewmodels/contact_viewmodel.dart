import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/contact/domain/entities/contact_message.dart';
import 'package:flutter_app/src/features/contact/domain/usecases/send_contact_message.dart';
import 'package:flutter_app/src/features/contact/domain/usecases/get_received_messages.dart';

class ContactViewModel extends ChangeNotifier {
  final SendContactMessage _sendContactMessage;
  final GetReceivedMessages _getReceivedMessages;

  ContactViewModel(this._sendContactMessage, this._getReceivedMessages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  List<ContactMessage> _receivedMessages = [];
  List<ContactMessage> get receivedMessages => _receivedMessages;

  // Form fields
  String subject = '';
  String message = '';

  final Map<String, String?> _fieldErrors = {};
  Map<String, String?> get fieldErrors => _fieldErrors;

  void setSubject(String v) {
    subject = v;
    _fieldErrors.remove('subject');
    notifyListeners();
  }

  void setMessage(String v) {
    message = v;
    _fieldErrors.remove('message');
    notifyListeners();
  }

  void resetForm() {
    subject = '';
    message = '';
    _fieldErrors.clear();
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  bool validateForm() {
    _fieldErrors.clear();

    if (subject.isEmpty || subject.trim().isEmpty) {
      _fieldErrors['subject'] = 'El asunto es requerido';
    } else if (subject.trim().length < 5) {
      _fieldErrors['subject'] = 'El asunto debe tener al menos 5 caracteres';
    }

    if (message.isEmpty || message.trim().isEmpty) {
      _fieldErrors['message'] = 'El mensaje es requerido';
    } else if (message.trim().length < 20) {
      _fieldErrors['message'] = 'El mensaje debe tener al menos 20 caracteres';
    }

    notifyListeners();
    return _fieldErrors.isEmpty;
  }

  Future<bool> sendMessage({
    required String senderUserId,
    required String senderName,
    required String senderEmail,
    required String recipientCompanyId,
    required String recipientCompanyName,
    String? productId,
    String? productName,
  }) async {
    if (!validateForm()) return false;

    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final contactMessage = ContactMessage(
        id: '',
        senderUserId: senderUserId,
        senderName: senderName,
        senderEmail: senderEmail,
        recipientCompanyId: recipientCompanyId,
        recipientCompanyName: recipientCompanyName,
        subject: subject.trim(),
        message: message.trim(),
        productId: productId,
        productName: productName,
      );

      await _sendContactMessage(contactMessage);
      _successMessage = 'Mensaje enviado correctamente';
      resetForm();
      return true;
    } catch (e) {
      _error = 'Error al enviar el mensaje: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReceivedMessages(String companyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _receivedMessages = await _getReceivedMessages(companyId);
    } catch (e) {
      _error = 'Error al cargar mensajes: ${e.toString()}';
      _receivedMessages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

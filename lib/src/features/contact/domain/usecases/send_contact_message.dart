import 'package:flutter_app/src/features/contact/domain/entities/contact_message.dart';
import 'package:flutter_app/src/features/contact/domain/repositories/contact_repository.dart';

class SendContactMessage {
  final ContactRepository repository;

  SendContactMessage(this.repository);

  Future<void> call(ContactMessage message) {
    return repository.sendContactMessage(message);
  }
}

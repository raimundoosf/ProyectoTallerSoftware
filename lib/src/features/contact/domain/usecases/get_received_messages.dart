import 'package:flutter_app/src/features/contact/domain/entities/contact_message.dart';
import 'package:flutter_app/src/features/contact/domain/repositories/contact_repository.dart';

class GetReceivedMessages {
  final ContactRepository repository;

  GetReceivedMessages(this.repository);

  Future<List<ContactMessage>> call(String companyId) {
    return repository.getReceivedMessages(companyId);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/family_repository.dart';

/// OOP Domain Command representing an intent to add/invite a family member.
class AddFamilyCommand {
  final String identifier;
  const AddFamilyCommand(this.identifier);
}

/// Abstract contract for the Add Family Member Use Case (OOP Abstraction).
abstract class IAddFamilyUseCase {
  Future<void> execute(AddFamilyCommand command, int availableSlots);
}

/// Concrete implementation of [IAddFamilyUseCase] encapsulating business logic (OOP Encapsulation).
class AddFamilyUseCase implements IAddFamilyUseCase {
  final IFamilyRepository _repository;

  const AddFamilyUseCase(this._repository);

  @override
  Future<void> execute(AddFamilyCommand command, int availableSlots) async {
    final cleanIdentifier = command.identifier.trim();
    if (cleanIdentifier.isEmpty) {
      throw ArgumentError('Email or username cannot be empty.');
    }
    if (availableSlots <= 0) {
      throw StateError('You have reached the 40-member capacity limit.');
    }
    await _repository.sendFamilyRequest(cleanIdentifier);
  }
}

/// OOP Dependency Injection provider binding [IAddFamilyUseCase]
final addFamilyUseCaseProvider = Provider<IAddFamilyUseCase>((ref) {
  final repo = ref.watch(familyRepositoryProvider);
  return AddFamilyUseCase(repo);
});

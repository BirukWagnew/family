import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/family_member.dart';
import '../../domain/family_request.dart';
import '../../domain/add_family_use_case.dart';
import '../../data/family_repository.dart';

part 'family_controller.freezed.dart';

@freezed
abstract class FamilyState with _$FamilyState {
  const factory FamilyState({
    @Default([]) List<FamilyMember> members,
    @Default([]) List<FamilyRequest> pendingRequests,
    @Default(false) bool isLoading,
    String? error,
  }) = _FamilyState;

  const FamilyState._();

  int get availableSlots {
    final outgoingPending = pendingRequests.where((r) => r.direction == RequestDirection.outgoing).length;
    return 40 - members.length - outgoingPending;
  }
}

final familyControllerProvider =
    NotifierProvider<FamilyController, FamilyState>(FamilyController.new);

class FamilyController extends Notifier<FamilyState> {
  late IFamilyRepository _repo;
  late IAddFamilyUseCase _addFamilyUseCase;

  @override
  FamilyState build() {
    _repo = ref.watch(familyRepositoryProvider);
    _addFamilyUseCase = ref.watch(addFamilyUseCaseProvider);
    _loadFamilyData();
    return const FamilyState();
  }

  Future<void> refresh() => _loadFamilyData();

  Future<void> _loadFamilyData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final members = await _repo.getFamilyMembers();
      final requests = await _repo.getPendingRequests();
      state = state.copyWith(
        members: members,
        pendingRequests: requests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendRequest(String identifier) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _addFamilyUseCase.execute(
        AddFamilyCommand(identifier),
        state.availableSlots,
      );
      // Refresh requests after sending
      final requests = await _repo.getPendingRequests();
      state = state.copyWith(pendingRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> acceptRequest(String requestId) async {
    if (state.members.length >= 40) {
      state = state.copyWith(error: "You have reached the 40-member capacity limit.");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.acceptRequest(requestId);
      await _loadFamilyData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> rejectRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.rejectRequest(requestId);
      await _loadFamilyData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

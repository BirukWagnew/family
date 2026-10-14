import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/conversation.dart';
import '../../data/message_repository.dart';

final conversationsControllerProvider = AsyncNotifierProvider<ConversationsController, List<Conversation>>(() {
  return ConversationsController();
});

class ConversationsController extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() async {
    final repo = ref.watch(messageRepositoryProvider);
    return repo.getConversations();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(messageRepositoryProvider);
      final conversations = await repo.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

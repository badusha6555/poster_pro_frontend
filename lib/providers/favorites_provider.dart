import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/template.dart';
import 'core_providers.dart';

class FavoritesController extends StateNotifier<AsyncValue<List<TemplateSummary>>> {
  FavoritesController(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final page = await _ref.read(favoriteRepositoryProvider).getFavorites();
      state = AsyncValue.data(page.content);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(TemplateSummary template) async {
    final current = state;
    if (current is! AsyncData<List<TemplateSummary>>) return;

    final optimistic = current.value.where((t) => t.id != template.id).toList();
    state = AsyncValue.data(optimistic);

    try {
      await _ref.read(favoriteRepositoryProvider).removeFavorite(template.id);
    } catch (_) {
      state = current;
      rethrow;
    }
  }
}

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, AsyncValue<List<TemplateSummary>>>((ref) {
  return FavoritesController(ref);
});

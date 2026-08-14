import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/template.dart';
import 'core_providers.dart';

class TemplateDetailController extends StateNotifier<AsyncValue<TemplateDetail>> {
  TemplateDetailController(this._ref, this.templateId) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;
  final int templateId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final detail = await _ref.read(templateRepositoryProvider).getTemplate(templateId);
      state = AsyncValue.data(detail);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite() async {
    final current = state;
    if (current is! AsyncData<TemplateDetail>) return;
    final detail = current.value;
    final wasFavorited = detail.summary.isFavorited;

    final optimistic = TemplateDetail(
      summary: detail.summary.copyWith(isFavorited: !wasFavorited),
      schemaJson: detail.schemaJson,
      createdAt: detail.createdAt,
      updatedAt: detail.updatedAt,
    );
    state = AsyncValue.data(optimistic);

    try {
      final favoriteRepo = _ref.read(favoriteRepositoryProvider);
      if (wasFavorited) {
        await favoriteRepo.removeFavorite(templateId);
      } else {
        await favoriteRepo.addFavorite(templateId);
      }
    } catch (_) {
      state = current;
      rethrow;
    }
  }
}

final templateDetailControllerProvider = StateNotifierProvider.family<
    TemplateDetailController, AsyncValue<TemplateDetail>, int>((ref, templateId) {
  return TemplateDetailController(ref, templateId);
});

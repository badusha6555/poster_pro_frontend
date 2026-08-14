import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/template.dart';
import 'core_providers.dart';

class HomeState {
  const HomeState({
    this.templates = const AsyncValue.loading(),
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  final AsyncValue<List<TemplateSummary>> templates;
  final int? selectedCategoryId;
  final String searchQuery;

  HomeState copyWith({
    AsyncValue<List<TemplateSummary>>? templates,
    int? Function()? selectedCategoryId,
    String? searchQuery,
  }) {
    return HomeState(
      templates: templates ?? this.templates,
      selectedCategoryId:
          selectedCategoryId != null ? selectedCategoryId() : this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._ref) : super(const HomeState()) {
    loadTemplates();
  }

  final Ref _ref;
  Timer? _debounce;

  Future<void> loadTemplates() async {
    state = state.copyWith(templates: const AsyncValue.loading());
    try {
      final page = await _ref.read(templateRepositoryProvider).getTemplates(
            categoryId: state.selectedCategoryId,
            search: state.searchQuery,
          );
      state = state.copyWith(templates: AsyncValue.data(page.content));
    } catch (e, st) {
      state = state.copyWith(templates: AsyncValue.error(e, st));
    }
  }

  void selectCategory(int? categoryId) {
    if (categoryId == state.selectedCategoryId) return;
    state = state.copyWith(selectedCategoryId: () => categoryId);
    loadTemplates();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadTemplates);
  }

  Future<void> toggleFavorite(TemplateSummary template) async {
    final favoriteRepo = _ref.read(favoriteRepositoryProvider);
    final current = state.templates;
    if (current is! AsyncData<List<TemplateSummary>>) return;

    final optimistic = current.value
        .map((t) => t.id == template.id ? t.copyWith(isFavorited: !t.isFavorited) : t)
        .toList();
    state = state.copyWith(templates: AsyncValue.data(optimistic));

    try {
      if (template.isFavorited) {
        await favoriteRepo.removeFavorite(template.id);
      } else {
        await favoriteRepo.addFavorite(template.id);
      }
    } catch (_) {
      // Revert on failure.
      state = state.copyWith(templates: current);
      rethrow;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gold_rate_profile.dart';
import 'core_providers.dart';

class GoldRateController extends StateNotifier<AsyncValue<GoldRateProfile>> {
  GoldRateController(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _ref.read(goldRateRepositoryProvider).getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(GoldRateProfile updated) async {
    final saved = await _ref.read(goldRateRepositoryProvider).updateProfile(updated);
    state = AsyncValue.data(saved);
  }
}

final goldRateControllerProvider =
    StateNotifierProvider<GoldRateController, AsyncValue<GoldRateProfile>>((ref) {
  return GoldRateController(ref);
});

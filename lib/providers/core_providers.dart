import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/gold_rate_repository.dart';
import '../repositories/template_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Bumped by the Dio client whenever a request comes back 401, so
/// [AuthController] can react without dioProvider depending on it directly
/// (that would create a provider read cycle at construction time).
final unauthorizedSignalProvider = StateProvider<int>((ref) => 0);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return createDioClient(
    storage: storage,
    onUnauthorized: () {
      ref.read(unauthorizedSignalProvider.notifier).state++;
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(dioProvider));
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository(ref.watch(dioProvider));
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(ref.watch(dioProvider));
});

final goldRateRepositoryProvider = Provider<GoldRateRepository>((ref) {
  return GoldRateRepository(ref.watch(dioProvider));
});

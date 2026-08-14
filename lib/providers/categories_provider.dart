import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import 'core_providers.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.read(categoryRepositoryProvider).getCategories();
});

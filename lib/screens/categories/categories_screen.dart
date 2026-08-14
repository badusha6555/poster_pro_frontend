import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/api_error.dart';
import '../../providers/categories_provider.dart';
import '../../providers/home_provider.dart';
import '../templates/template_list_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Categories', style: Theme.of(context).textTheme.headlineMedium),
        ),
        Expanded(
          child: categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (error, _) => Center(
              child: Text(
                error is ApiError ? error.message : 'Failed to load categories',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            data: (categories) {
              if (categories.isEmpty) {
                return const Center(
                  child: Text('No categories yet', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.4,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final category = categories[i];
                  return _CategoryTile(
                    label: category.name,
                    onTap: () {
                      ref.read(homeControllerProvider.notifier).selectCategory(category.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TemplateListScreen(title: category.name),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.category_outlined, color: AppColors.gold, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

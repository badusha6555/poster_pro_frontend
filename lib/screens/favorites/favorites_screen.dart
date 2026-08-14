import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/api_error.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/template_card.dart';
import '../template/template_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Favorites', style: Theme.of(context).textTheme.headlineMedium),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () => ref.read(favoritesControllerProvider.notifier).load(),
            child: favoritesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (error, _) => Center(
                child: Text(
                  error is ApiError ? error.message : 'Failed to load favorites',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              data: (favorites) {
                if (favorites.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 80),
                      Icon(Icons.favorite_border, color: AppColors.textMuted, size: 40),
                      SizedBox(height: 12),
                      Center(
                        child: Text('No favorites yet', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, i) {
                    final template = favorites[i];
                    return TemplateCard(
                      template: template,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TemplateDetailScreen(templateId: template.id),
                          ),
                        );
                      },
                      onToggleFavorite: () async {
                        try {
                          await ref.read(favoritesControllerProvider.notifier).remove(template);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not update favorite')),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

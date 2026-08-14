import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/api_error.dart';
import '../../providers/home_provider.dart';
import '../../widgets/template_card.dart';
import '../template/template_detail_screen.dart';

/// Full, non-paginated grid backed by [homeControllerProvider] — reused for
/// the Home screen's "See all" link and for tapping a category tile.
class TemplateListScreen extends ConsumerWidget {
  const TemplateListScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: homeState.templates.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (error, _) => Center(
          child: Text(
            error is ApiError ? error.message : 'Failed to load templates',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(
              child: Text('No templates found', style: TextStyle(color: AppColors.textSecondary)),
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
            itemCount: templates.length,
            itemBuilder: (context, i) {
              final template = templates[i];
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
                    await ref.read(homeControllerProvider.notifier).toggleFavorite(template);
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
    );
  }
}

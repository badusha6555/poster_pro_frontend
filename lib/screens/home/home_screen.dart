import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/api_error.dart';
import '../../providers/auth_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/gold_rate_card.dart';
import '../../widgets/template_card.dart';
import '../shell/app_shell.dart';
import '../template/template_detail_screen.dart';
import '../templates/template_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final homeState = ref.watch(homeControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () => ref.read(homeControllerProvider.notifier).loadTemplates(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back,', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(
                      authState.shopName ?? 'Shop',
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                onPressed: () => ref.read(shellIndexProvider.notifier).state = 3,
              ),
              IconButton(
                // TODO: wire to a real notifications endpoint once one exists on the backend.
                icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: (value) => ref.read(homeControllerProvider.notifier).search(value),
            decoration: const InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 16),
          GoldRateCard(onUpdate: () => ref.read(shellIndexProvider.notifier).state = 3),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              loading: () => const Center(
                child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (categories) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryPill(
                        label: 'All',
                        selected: homeState.selectedCategoryId == null,
                        onTap: () => ref.read(homeControllerProvider.notifier).selectCategory(null),
                      ),
                    ),
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryPill(
                          label: category.name,
                          selected: homeState.selectedCategoryId == category.id,
                          onTap: () => ref.read(homeControllerProvider.notifier).selectCategory(category.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured Templates', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TemplateListScreen(title: 'All Templates')),
                  );
                },
                child: const Text('See all', style: TextStyle(color: AppColors.gold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          homeState.templates.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  error is ApiError ? error.message : 'Failed to load templates',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            data: (templates) {
              if (templates.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No templates found', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }
              final featured = templates.take(6).toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: featured.length,
                itemBuilder: (context, i) {
                  final template = featured[i];
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
        ],
      ),
    );
  }
}

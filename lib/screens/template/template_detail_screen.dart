import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/api_error.dart';
import '../../models/gold_rate_profile.dart';
import '../../models/poster_result.dart';
import '../../providers/core_providers.dart';
import '../../providers/gold_rate_provider.dart';
import '../../providers/template_detail_provider.dart';
import '../../widgets/gold_gradient_button.dart';
import '../shell/app_shell.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  const TemplateDetailScreen({super.key, required this.templateId});

  final int templateId;

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  final _rate22kController = TextEditingController();
  final _rate18kController = TextEditingController();
  final _rate14kController = TextEditingController();
  final _rate9kController = TextEditingController();
  bool _ratesInitialized = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _rate22kController.dispose();
    _rate18kController.dispose();
    _rate14kController.dispose();
    _rate9kController.dispose();
    super.dispose();
  }

  void _prefillRatesIfNeeded(AsyncValue<GoldRateProfile> goldRateAsync) {
    if (_ratesInitialized) return;
    final profile = goldRateAsync.value;
    if (profile == null) return;
    _rate22kController.text = profile.rate22k916.toStringAsFixed(0);
    _rate18kController.text = profile.rate18k.toStringAsFixed(0);
    _rate14kController.text = profile.rate14k.toStringAsFixed(0);
    _rate9kController.text = profile.rate9k.toStringAsFixed(0);
    _ratesInitialized = true;
  }

  Future<void> _handleGeneratePoster() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final result = await ref.read(templateRepositoryProvider).generatePoster(
            widget.templateId,
            rate22k916: double.tryParse(_rate22kController.text),
            rate18k: double.tryParse(_rate18kController.text),
            rate14k: double.tryParse(_rate14kController.text),
            rate9k: double.tryParse(_rate9kController.text),
          );
      if (!mounted) return;
      _showPosterResultDialog(result);
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiError ? e.message : 'Could not generate poster';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showPosterResultDialog(PosterResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Poster ready', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: result.url,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: AppColors.gold))),
                errorWidget: (context, url, error) =>
                    const SizedBox(height: 160, child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted))),
              ),
            ),
            const SizedBox(height: 12),
            Text('Format: ${result.format}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            if (result.urlExpiresAt != null)
              Text(
                'Link expires: ${result.urlExpiresAt}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(templateDetailControllerProvider(widget.templateId));
    final goldRateAsync = ref.watch(goldRateControllerProvider);
    _prefillRatesIfNeeded(goldRateAsync);

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (error, _) => Center(
          child: Text(
            error is ApiError ? error.message : 'Failed to load template',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (detail) {
          final t = detail.summary;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                backgroundColor: AppColors.background,
                leading: _CircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                actions: [
                  _CircleIconButton(
                    icon: t.isFavorited ? Icons.favorite : Icons.favorite_border,
                    iconColor: t.isFavorited ? AppColors.gold : AppColors.textPrimary,
                    onTap: () async {
                      try {
                        await ref
                            .read(templateDetailControllerProvider(widget.templateId).notifier)
                            .toggleFavorite();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not update favorite')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      // TODO: no share/export endpoint confirmed yet on the backend.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing coming soon')),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: t.thumbnailUrl == null || t.thumbnailUrl!.isEmpty
                      ? const ColoredBox(
                          color: AppColors.surfaceAlt,
                          child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 64),
                        )
                      : CachedNetworkImage(imageUrl: t.thumbnailUrl!, fit: BoxFit.cover),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (t.planTierMin != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: goldGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.planTierMin!,
                                style: const TextStyle(
                                  color: Color(0xFF1A1206),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (t.isFestival)
                            const Text('Festival Special', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(t.title, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      // Backend TemplateDetailDto has no `sku` field — using
                      // the template id as the closest identifier available.
                      Text(
                        'Template · ID ${t.id}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${t.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('Set Rates', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      const Text(
                        // Note: the backend's GoldRateDto stores 4 flat karat
                        // rates (22K/916, 18K, 14K, 9K) — not the 6
                        // karat/weight combinations shown in the design mock.
                        'Editable',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      _RateField(label: '22K / 916', controller: _rate22kController),
                      const SizedBox(height: 10),
                      _RateField(label: '18K', controller: _rate18kController),
                      const SizedBox(height: 10),
                      _RateField(label: '14K', controller: _rate14kController),
                      const SizedBox(height: 10),
                      _RateField(label: '9K', controller: _rate9kController),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Rates auto-fill from your saved profile.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () => ref.read(shellIndexProvider.notifier).state = 3,
                            child: const Text('Edit profile', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      GoldGradientButton(
                        label: 'Generate Poster',
                        icon: Icons.auto_awesome,
                        loading: _isGenerating,
                        onPressed: _handleGeneratePoster,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RateField extends StatelessWidget {
  const _RateField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(color: AppColors.textSecondary),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xB3120E0A), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

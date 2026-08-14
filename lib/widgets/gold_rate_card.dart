import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/gold_rate_provider.dart';

/// Home screen's "Today's Gold Rate" card, showing the 22K/916 rate with
/// an "Update" link to the Profile tab's editable gold rate form.
class GoldRateCard extends ConsumerWidget {
  const GoldRateCard({super.key, required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldRate = ref.watch(goldRateControllerProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up, color: Color(0xFF1A1206)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Gold Rate",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                goldRate.when(
                  data: (rate) => Text(
                    '₹${rate.rate22k916.toStringAsFixed(0)} / g (22K)',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  ),
                  error: (_, _) => const Text(
                    'Unavailable',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUpdate,
            child: const Text('Update', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

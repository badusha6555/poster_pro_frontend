import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/api_error.dart';
import '../../models/gold_rate_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gold_rate_provider.dart';
import '../../widgets/gold_gradient_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _rate22kController = TextEditingController();
  final _rate18kController = TextEditingController();
  final _rate14kController = TextEditingController();
  final _rate9kController = TextEditingController();
  bool _ratesInitialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _rate22kController.dispose();
    _rate18kController.dispose();
    _rate14kController.dispose();
    _rate9kController.dispose();
    super.dispose();
  }

  void _prefillIfNeeded(GoldRateProfile? profile) {
    if (_ratesInitialized || profile == null) return;
    _rate22kController.text = profile.rate22k916.toStringAsFixed(0);
    _rate18kController.text = profile.rate18k.toStringAsFixed(0);
    _rate14kController.text = profile.rate14k.toStringAsFixed(0);
    _rate9kController.text = profile.rate9k.toStringAsFixed(0);
    _ratesInitialized = true;
  }

  Future<void> _save() async {
    final updated = GoldRateProfile(
      rate22k916: double.tryParse(_rate22kController.text) ?? 0,
      rate18k: double.tryParse(_rate18kController.text) ?? 0,
      rate14k: double.tryParse(_rate14kController.text) ?? 0,
      rate9k: double.tryParse(_rate9kController.text) ?? 0,
    );
    setState(() => _saving = true);
    try {
      await ref.read(goldRateControllerProvider.notifier).save(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gold rates updated')),
        );
      }
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final goldRateAsync = ref.watch(goldRateControllerProvider);
    _prefillIfNeeded(goldRateAsync.value);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.gold,
                child: Text(
                  (authState.shopName?.isNotEmpty ?? false) ? authState.shopName![0].toUpperCase() : '?',
                  style: const TextStyle(color: Color(0xFF1A1206), fontWeight: FontWeight.w700, fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.shopName ?? '',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(authState.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Gold Rate Profile', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text(
          'Used to auto-fill rates on every template.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 14),
        if (goldRateAsync.isLoading && !_ratesInitialized)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          )
        else ...[
          _RateField(label: '22K / 916', controller: _rate22kController),
          const SizedBox(height: 10),
          _RateField(label: '18K', controller: _rate18kController),
          const SizedBox(height: 10),
          _RateField(label: '14K', controller: _rate14kController),
          const SizedBox(height: 10),
          _RateField(label: '9K', controller: _rate9kController),
          const SizedBox(height: 18),
          GoldGradientButton(label: 'Save Rates', loading: _saving, onPressed: _save),
        ],
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout, color: AppColors.danger),
          label: const Text('Log out', style: TextStyle(color: AppColors.danger)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.danger),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
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

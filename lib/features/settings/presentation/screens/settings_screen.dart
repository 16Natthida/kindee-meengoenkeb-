import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/settings_models.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _updateField(
    BuildContext context,
    WidgetRef ref, {
    String? themeMode,
    String? currency,
    bool? notifyBudgetLow,
    bool? notifyExpiry,
  }) async {
    try {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.updateSettings(
        themeMode: themeMode,
        currency: currency,
        notifyBudgetLow: notifyBudgetLow,
        notifyExpiry: notifyExpiry,
      );
      ref.invalidate(userSettingsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.from(e).message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorStateView(
          message: AppException.from(e).message,
          onRetry: () => ref.invalidate(userSettingsProvider),
        ),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader('การแสดงผล'),
              Card(
                child: Column(
                  children: themeModeOptions.map((option) {
                    final (value, label) = option;
                    return RadioListTile<String>(
                      title: Text(label),
                      value: value,
                      groupValue: settings.themeMode,
                      onChanged: (v) {
                        if (v != null) {
                          _updateField(context, ref, themeMode: v);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader('หน่วยเงิน'),
              Card(
                child: Column(
                  children: currencyOptions.map((option) {
                    final (value, label) = option;
                    return RadioListTile<String>(
                      title: Text(label),
                      value: value,
                      groupValue: settings.currency,
                      onChanged: (v) {
                        if (v != null) {
                          _updateField(context, ref, currency: v);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader('การแจ้งเตือน'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('แจ้งเตือนเมื่องบเหลือน้อย/เกินงบ'),
                      value: settings.notifyBudgetLow,
                      onChanged: (v) => _updateField(context, ref, notifyBudgetLow: v),
                    ),
                    SwitchListTile(
                      title: const Text('แจ้งเตือนวัตถุดิบใกล้หมดอายุ'),
                      value: settings.notifyExpiry,
                      onChanged: (v) => _updateField(context, ref, notifyExpiry: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader('เกี่ยวกับแอป'),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('กินดี มีเงินเก็บ'),
                  subtitle: Text('เวอร์ชัน 0.1.0'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

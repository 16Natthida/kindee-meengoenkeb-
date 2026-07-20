import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/settings_models.dart';

class SettingsRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// user_settings ถูกสร้างให้อัตโนมัติตอนสมัครสมาชิกผ่าน Trigger `on_auth_user_created`
  /// ถ้าด้วยเหตุผลใดยังไม่มีแถว (บัญชีเก่าก่อนมี Trigger) จะสร้างค่าเริ่มต้นให้
  Future<UserSettingsModel> fetchOrCreateSettings() async {
    try {
      final userId = SupabaseService.currentUserId;
      final existing = await _client
          .from(SupabaseTables.userSettings)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) return UserSettingsModel.fromMap(existing);

      final created = await _client
          .from(SupabaseTables.userSettings)
          .insert({'user_id': userId})
          .select()
          .single();
      return UserSettingsModel.fromMap(created);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<UserSettingsModel> updateSettings({
    String? themeMode,
    String? currency,
    bool? notifyBudgetLow,
    bool? notifyExpiry,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final data = <String, dynamic>{};
      if (themeMode != null) data['theme_mode'] = themeMode;
      if (currency != null) data['currency'] = currency;
      if (notifyBudgetLow != null) data['notify_budget_low'] = notifyBudgetLow;
      if (notifyExpiry != null) data['notify_expiry'] = notifyExpiry;
      if (data.isEmpty) return fetchOrCreateSettings();

      final row = await _client
          .from(SupabaseTables.userSettings)
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();
      return UserSettingsModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/app_user.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  Stream<AuthState> get authStateChanges => SupabaseService.authStateChanges;

  bool get isLoggedIn => SupabaseService.isLoggedIn;

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (res.user == null) {
        throw const AppException('สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw const AppException('เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<AppUser?> fetchCurrentProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;
    try {
      final row = await _client
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row == null) return null;
      return AppUser.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<AppUser> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final updateData = <String, dynamic>{'username': username};
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      final row = await _client
          .from(SupabaseTables.profiles)
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();
      return AppUser.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

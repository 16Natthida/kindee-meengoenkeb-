import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// สถานะ Auth แบบ Stream ตรงจาก Supabase (ใช้ตัดสินใจ Route ใน GoRouter)
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// โปรไฟล์ผู้ใช้ปัจจุบัน (ตาราง profiles) — โหลดใหม่เมื่อ auth state เปลี่ยน
final currentProfileProvider = FutureProvider<AppUser?>((ref) async {
  ref.watch(authStateChangesProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.fetchCurrentProfile();
});

class AuthFormController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repo;

  AuthFormController(this._repo) : super(const AsyncData(null));

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _repo.signIn(email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(AppException.from(e), st);
      return false;
    }
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signUp(username: username, email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(AppException.from(e), st);
      return false;
    }
  }

  Future<bool> sendResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      await _repo.sendPasswordResetEmail(email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(AppException.from(e), st);
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}

final authFormControllerProvider =
    StateNotifierProvider<AuthFormController, AsyncValue<void>>((ref) {
  return AuthFormController(ref.watch(authRepositoryProvider));
});

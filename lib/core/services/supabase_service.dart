import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';

/// จุดเดียวที่ Initialize และเข้าถึง Supabase Client
/// Repository ทุกตัวต้องเรียกผ่านคลาสนี้ ห้าม import supabase_flutter ตรงใน Widget
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw const AppException(
        'ไม่พบการตั้งค่า Supabase กรุณาตรวจสอบไฟล์ .env',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String get currentUserId {
    final user = currentUser;
    if (user == null) {
      throw const AppException('เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
    }
    return user.id;
  }

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// อัปโหลดรูปไปยัง path: {bucket}/{user_id}/{filename}
  /// สอดคล้องกับ Storage RLS Policy ที่กำหนดไว้ใน 002_rls_policies.sql
  static Future<String> uploadImage({
    required String bucket,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final userId = currentUserId;
      final path = '$userId/$fileName';
      await client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  static Future<void> deleteImage({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

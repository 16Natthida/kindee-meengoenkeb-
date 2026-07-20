import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception กลางของแอป ทุก Error ที่โยนออกจาก Repository/Service
/// ต้องถูกแปลงเป็น AppException ก่อนเสมอ เพื่อให้ UI แสดงข้อความไทยได้แน่นอน
class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, {this.cause});

  @override
  String toString() => message;

  /// แปลง Error ที่มาจากภายนอก (Supabase, Network, ฯลฯ) ให้เป็นข้อความภาษาไทย
  factory AppException.from(Object error) {
    if (error is AppException) return error;

    if (error is AuthException) {
      return AppException(_mapAuthError(error.message));
    }

    if (error is PostgrestException) {
      return AppException(_mapPostgrestError(error));
    }

    if (error is StorageException) {
      return const AppException('อัปโหลดหรือดาวน์โหลดรูปภาพไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
    }

    final text = error.toString().toLowerCase();
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network')) {
      return const AppException('ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบการเชื่อมต่อแล้วลองใหม่');
    }

    return const AppException('เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง');
  }

  static String _mapAuthError(String raw) {
    final text = raw.toLowerCase();
    if (text.contains('invalid login credentials')) {
      return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    }
    if (text.contains('email not confirmed')) {
      return 'กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ';
    }
    if (text.contains('user already registered') ||
        text.contains('already registered')) {
      return 'อีเมลนี้ถูกใช้สมัครสมาชิกแล้ว';
    }
    if (text.contains('password should be at least')) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
    }
    if (text.contains('session') && text.contains('expired')) {
      return 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง';
    }
    if (text.contains('rate limit')) {
      return 'มีการร้องขอถี่เกินไป กรุณารอสักครู่แล้วลองใหม่';
    }
    return 'เกิดข้อผิดพลาดในการยืนยันตัวตน กรุณาลองใหม่อีกครั้ง';
  }

  static String _mapPostgrestError(PostgrestException error) {
    final code = error.code;
    if (code == '23505') return 'ข้อมูลนี้มีอยู่แล้วในระบบ';
    if (code == '23503') return 'ไม่สามารถดำเนินการได้ เนื่องจากมีข้อมูลที่เกี่ยวข้องอยู่';
    if (code == '23514') return 'ข้อมูลที่กรอกไม่ถูกต้องตามเงื่อนไข';
    if (code == '42501' || code == 'PGRST301') {
      return 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้';
    }
    return 'เกิดข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล กรุณาลองใหม่อีกครั้ง';
  }
}

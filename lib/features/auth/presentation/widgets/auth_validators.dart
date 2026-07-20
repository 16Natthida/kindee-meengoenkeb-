import 'package:flutter/widgets.dart';

class AuthValidators {
  AuthValidators._();

  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอกอีเมล';
    if (!_emailRegex.hasMatch(value.trim())) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
    if (value.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอกชื่อผู้ใช้งาน';
    if (value.trim().length < 2) return 'ชื่อผู้ใช้งานสั้นเกินไป';
    return null;
  }

  static String? Function(String?) confirmPassword(
    TextEditingController original,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
      if (value != original.text) return 'รหัสผ่านไม่ตรงกัน';
      return null;
    };
  }
}

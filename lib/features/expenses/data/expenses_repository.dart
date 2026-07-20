import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/expense_models.dart';
import '../domain/recurring_expense_models.dart';

const int expensePageSize = 20;

class ExpensesRepository {
  final SupabaseClient _client = SupabaseService.client;
  final _uuid = const Uuid();

  static const _selectWithCategory =
      '*, budget_categories(id, name, icon)';

  Future<List<ExpenseModel>> fetchExpenses({
    required ExpenseFilter filter,
    required int page,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      var query = _client
          .from(SupabaseTables.expenses)
          .select(_selectWithCategory)
          .eq('user_id', userId);

      if (filter.fromDate != null) {
        query = query.gte('expense_date', _dateOnly(filter.fromDate!));
      }
      if (filter.toDate != null) {
        query = query.lte('expense_date', _dateOnly(filter.toDate!));
      }
      if (filter.categoryId != null) {
        query = query.eq('category_id', filter.categoryId!);
      }
      if (filter.paymentMethod != null) {
        query = query.eq('payment_method', filter.paymentMethod!);
      }
      if (filter.searchText.trim().isNotEmpty) {
        query = query.ilike('title', '%${filter.searchText.trim()}%');
      }

      final from = page * expensePageSize;
      final to = from + expensePageSize - 1;

      final rows = await query
          .order('expense_date', ascending: !filter.sortDescending)
          .order('created_at', ascending: !filter.sortDescending)
          .range(from, to);

      return rows.map((r) => ExpenseModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// ยอดรวมตามตัวกรองปัจจุบัน (ไม่จำกัด page เพื่อให้ยอดรวมถูกต้อง)
  Future<double> fetchFilteredTotal({required ExpenseFilter filter}) async {
    try {
      final userId = SupabaseService.currentUserId;
      var query = _client
          .from(SupabaseTables.expenses)
          .select('amount')
          .eq('user_id', userId);

      if (filter.fromDate != null) {
        query = query.gte('expense_date', _dateOnly(filter.fromDate!));
      }
      if (filter.toDate != null) {
        query = query.lte('expense_date', _dateOnly(filter.toDate!));
      }
      if (filter.categoryId != null) {
        query = query.eq('category_id', filter.categoryId!);
      }
      if (filter.paymentMethod != null) {
        query = query.eq('payment_method', filter.paymentMethod!);
      }
      if (filter.searchText.trim().isNotEmpty) {
        query = query.ilike('title', '%${filter.searchText.trim()}%');
      }

      final rows = await query;
      double total = 0;
      for (final r in rows) {
        total += (r['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ExpenseModel> fetchById(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.expenses)
          .select(_selectWithCategory)
          .eq('id', id)
          .eq('user_id', userId)
          .single();
      return ExpenseModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ExpenseModel> createExpense({
    required String title,
    required double amount,
    required String? categoryId,
    required String paymentMethod,
    String? note,
    String? receiptImageUrl,
    required DateTime expenseDate,
    String? expenseTime,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.expenses)
          .insert({
            'user_id': userId,
            'category_id': categoryId,
            'title': title,
            'amount': amount,
            'payment_method': paymentMethod,
            'note': note,
            'receipt_image_url': receiptImageUrl,
            'expense_date': _dateOnly(expenseDate),
            'expense_time': expenseTime,
          })
          .select(_selectWithCategory)
          .single();
      return ExpenseModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ExpenseModel> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String? categoryId,
    required String paymentMethod,
    String? note,
    String? receiptImageUrl,
    bool clearReceiptImage = false,
    required DateTime expenseDate,
    String? expenseTime,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final data = <String, dynamic>{
        'category_id': categoryId,
        'title': title,
        'amount': amount,
        'payment_method': paymentMethod,
        'note': note,
        'expense_date': _dateOnly(expenseDate),
        'expense_time': expenseTime,
      };
      if (clearReceiptImage) {
        data['receipt_image_url'] = null;
      } else if (receiptImageUrl != null) {
        data['receipt_image_url'] = receiptImageUrl;
      }

      final row = await _client
          .from(SupabaseTables.expenses)
          .update(data)
          .eq('id', id)
          .eq('user_id', userId)
          .select(_selectWithCategory)
          .single();
      return ExpenseModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.expenses)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// อัปโหลดรูปใบเสร็จ คืน public URL — path: receipts/{user_id}/{uuid}.jpg
  Future<String> uploadReceiptImage(Uint8List bytes) async {
    final fileName = '${_uuid.v4()}.jpg';
    return SupabaseService.uploadImage(
      bucket: AppConstants.receiptBucket,
      fileName: fileName,
      bytes: bytes,
    );
  }

  /// ลบรูปเดิมออกจาก Storage โดยแยก path จาก public URL
  Future<void> deleteReceiptImageByUrl(String url) async {
    try {
      final userId = SupabaseService.currentUserId;
      final marker = '${AppConstants.receiptBucket}/$userId/';
      final idx = url.indexOf(marker);
      if (idx == -1) return;
      final path = url.substring(idx + AppConstants.receiptBucket.length + 1);
      await SupabaseService.deleteImage(bucket: AppConstants.receiptBucket, path: path);
    } catch (_) {
      // การลบรูปเก่าไม่สำเร็จไม่ควรบล็อกการทำงานหลัก
    }
  }

  String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;

  Future<List<RecurringExpenseModel>> fetchRecurringExpenses() async {
    try {
      final userId = SupabaseService.currentUserId;
      final rows = await _client
          .from(SupabaseTables.recurringExpenses)
          .select()
          .eq('user_id', userId)
          .order('is_active', ascending: false)
          .order('next_run_date');
      return rows.map((r) => RecurringExpenseModel.fromMap(r)).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> createRecurringExpense({
    required String title,
    required double amount,
    String? categoryId,
    required String paymentMethod,
    String? note,
    required String frequency,
    required DateTime nextRunDate,
  }) async {
    try {
      await _client.from(SupabaseTables.recurringExpenses).insert({
        'user_id': SupabaseService.currentUserId,
        'title': title,
        'amount': amount,
        'category_id': categoryId,
        'payment_method': paymentMethod,
        'note': note,
        'frequency': frequency,
        'next_run_date': _dateOnly(nextRunDate),
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteRecurringExpense(String id) async {
    try {
      await _client.from(SupabaseTables.recurringExpenses).delete().eq(
            'id',
            id,
          ).eq('user_id', SupabaseService.currentUserId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> toggleRecurringExpense({required String id, required bool active}) async {
    try {
      await _client.from(SupabaseTables.recurringExpenses).update({
        'is_active': active,
      }).eq('id', id).eq('user_id', SupabaseService.currentUserId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<int> createDueRecurringExpenses() async {
    try {
      final userId = SupabaseService.currentUserId;
      final today = DateTime.now();
      final rows = await _client
          .from(SupabaseTables.recurringExpenses)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .lte('next_run_date', _dateOnly(today));
      for (final row in rows) {
        final date = DateTime.parse(row['next_run_date'] as String);
        await _client.from(SupabaseTables.expenses).insert({
          'user_id': userId,
          'category_id': row['category_id'],
          'title': row['title'],
          'amount': row['amount'],
          'payment_method': row['payment_method'],
          'note': row['note'],
          'expense_date': _dateOnly(date),
        });
        final frequency = row['frequency'] as String;
        final next = frequency == 'weekly'
            ? date.add(const Duration(days: 7))
            : DateTime(date.year, date.month + 1, date.day);
        await _client.from(SupabaseTables.recurringExpenses).update({
          'next_run_date': _dateOnly(next),
        }).eq('id', row['id']).eq('user_id', userId);
      }
      return rows.length;
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

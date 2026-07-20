import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/ingredient_models.dart';

class IngredientsRepository {
  final SupabaseClient _client = SupabaseService.client;
  final _uuid = const Uuid();

  Future<List<IngredientModel>> fetchIngredients({required IngredientFilter filter}) async {
    try {
      final userId = SupabaseService.currentUserId;
      var query = _client.from(SupabaseTables.ingredients).select().eq('user_id', userId);

      if (filter.category != null) {
        query = query.eq('category', filter.category!);
      }
      if (filter.searchText.trim().isNotEmpty) {
        query = query.ilike('name', '%${filter.searchText.trim()}%');
      }

      final rows = filter.sortByExpiry
          ? await query.order('expiry_date', ascending: true, nullsFirst: false)
          : await query.order('name', ascending: true);

      var ingredients = rows.map((r) => IngredientModel.fromMap(r)).toList();

      // สถานะเป็นค่าคำนวณสด กรองฝั่ง client เพื่อความถูกต้องเสมอ (ไม่พึ่ง column status ที่อาจไม่ sync)
      if (filter.status != null) {
        ingredients = ingredients.where((i) => i.computedStatus == filter.status).toList();
      }

      return ingredients;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<List<IngredientModel>> fetchAll() async {
    return fetchIngredients(filter: const IngredientFilter());
  }

  Future<IngredientModel> createIngredient({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    double minimumQuantity = 0,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? purchasePrice,
    required String storageLocation,
    String? imageUrl,
    String? note,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final row = await _client
          .from(SupabaseTables.ingredients)
          .insert({
            'user_id': userId,
            'name': name,
            'category': category,
            'quantity': quantity,
            'unit': unit,
            'minimum_quantity': minimumQuantity,
            'purchase_date': purchaseDate?.toIso8601String().split('T').first,
            'expiry_date': expiryDate?.toIso8601String().split('T').first,
            'purchase_price': purchasePrice,
            'storage_location': storageLocation,
            'image_url': imageUrl,
            'note': note,
          })
          .select()
          .single();
      return IngredientModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<IngredientModel> updateIngredient({
    required String id,
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required double minimumQuantity,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? purchasePrice,
    required String storageLocation,
    String? imageUrl,
    bool clearImage = false,
    String? note,
  }) async {
    try {
      final userId = SupabaseService.currentUserId;
      final data = <String, dynamic>{
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'minimum_quantity': minimumQuantity,
        'purchase_date': purchaseDate?.toIso8601String().split('T').first,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'purchase_price': purchasePrice,
        'storage_location': storageLocation,
        'note': note,
      };
      if (clearImage) {
        data['image_url'] = null;
      } else if (imageUrl != null) {
        data['image_url'] = imageUrl;
      }

      final row = await _client
          .from(SupabaseTables.ingredients)
          .update(data)
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();
      return IngredientModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> deleteIngredient(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client.from(SupabaseTables.ingredients).delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// เพิ่ม/ลดจำนวนแบบรวดเร็ว (ปุ่ม +/- บนการ์ด) ไม่ให้ติดลบ
  Future<IngredientModel> adjustQuantity({required String id, required double delta}) async {
    try {
      final userId = SupabaseService.currentUserId;
      final current = await _client
          .from(SupabaseTables.ingredients)
          .select('quantity')
          .eq('id', id)
          .eq('user_id', userId)
          .single();
      final newQty = ((current['quantity'] as num).toDouble() + delta).clamp(0, double.infinity);

      final row = await _client
          .from(SupabaseTables.ingredients)
          .update({'quantity': newQty})
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();
      return IngredientModel.fromMap(row);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> markOutOfStock(String id) async {
    try {
      final userId = SupabaseService.currentUserId;
      await _client
          .from(SupabaseTables.ingredients)
          .update({'quantity': 0})
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// ตัดวัตถุดิบตามรายการที่ยืนยันแล้ว (ใช้ตอนทำเมนูเสร็จ) — ลดจำนวนทีละรายการ ไม่ให้ติดลบ
  Future<void> deductIngredients(Map<String, double> quantityByIngredientId) async {
    try {
      for (final entry in quantityByIngredientId.entries) {
        await adjustQuantity(id: entry.key, delta: -entry.value);
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<String> uploadIngredientImage(Uint8List bytes) async {
    final fileName = '${_uuid.v4()}.jpg';
    return SupabaseService.uploadImage(
      bucket: AppConstants.ingredientBucket,
      fileName: fileName,
      bytes: bytes,
    );
  }

  Future<void> deleteIngredientImageByUrl(String url) async {
    try {
      final userId = SupabaseService.currentUserId;
      final marker = '${AppConstants.ingredientBucket}/$userId/';
      final idx = url.indexOf(marker);
      if (idx == -1) return;
      final path = url.substring(idx + AppConstants.ingredientBucket.length + 1);
      await SupabaseService.deleteImage(bucket: AppConstants.ingredientBucket, path: path);
    } catch (_) {
      // ไม่บล็อกการทำงานหลักถ้าลบรูปเก่าไม่สำเร็จ
    }
  }
}

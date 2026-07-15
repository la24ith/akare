// lib/core/cache/local_cache_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// تخزين مؤقت عام (key → JSON) لأي بيانات بدنا نعرضها Offline.
/// كل قيمة مخزّنة مع وقت التخزين، فتقدر لاحقًا تعرض "آخر تحديث: قبل ٣ ساعات".
class LocalCacheService {
  static const _boxName = 'app_cache';
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static Future<void> set(String key, Object jsonEncodable) async {
    final payload = {
      'data': jsonEncodable,
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _box.put(key, jsonEncode(payload));
  }

  static T? get<T>(String key, T Function(dynamic decodedData) fromJson) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      return fromJson(decoded['data']);
    } catch (_) {
      return null;
    }
  }

  static DateTime? cachedAt(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return DateTime.parse(
        (jsonDecode(raw as String) as Map)['cached_at'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hamro_futsal/core/cache/hive/hive_boxes.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';

typedef CacheIdOf<T> = Object? Function(T item);
typedef CacheJsonOf<T> = Map<String, dynamic> Function(T item);
typedef CacheFromJson<T> = T Function(Map<String, dynamic> json);

final class HiveCacheService {
  HiveCacheService._();

  static final HiveCacheService instance = HiveCacheService._();

  static const String _recordsKey = 'records';
  static const String _orderKey = 'order';
  static const String _metaKey = 'meta';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Future.wait(<Future<Box>>[
      Hive.openBox(HiveBoxes.home),
      Hive.openBox(HiveBoxes.filter),
      Hive.openBox(HiveBoxes.chat),
      Hive.openBox(HiveBoxes.wishlist),
    ]);
    _initialized = true;
  }

  Future<void> clearAll() async {
    if (!_initialized) return;
    await Future.wait(<Future<int>>[
      Hive.box(HiveBoxes.home).clear(),
      Hive.box(HiveBoxes.filter).clear(),
      Hive.box(HiveBoxes.chat).clear(),
      Hive.box(HiveBoxes.wishlist).clear(),
    ]);
  }

  Future<List<T>> readList<T>({
    required String boxName,
    required String scope,
    required CacheFromJson<T> fromJson,
  }) async {
    if (!_initialized) return <T>[];
    final Box box = Hive.box(boxName);
    final Map<String, dynamic> bucket = _stringMap(box.get(scope));
    final Map<String, dynamic> records = _stringMap(bucket[_recordsKey]);
    final List<String> order = _stringList(bucket[_orderKey]);

    final List<T> items = <T>[];
    final Iterable<String> keys = order.isEmpty ? records.keys : order;
    for (final String key in keys) {
      final Map<String, dynamic> json = _stringMap(records[key]);
      if (json.isEmpty) continue;
      items.add(fromJson(json));
    }
    return List<T>.unmodifiable(items);
  }

  Future<T?> readItem<T>({
    required String boxName,
    required String key,
    required CacheFromJson<T> fromJson,
  }) async {
    if (!_initialized) return null;
    final Map<String, dynamic> json = _stringMap(Hive.box(boxName).get(key));
    if (json.isEmpty) return null;
    return fromJson(json);
  }

  Future<bool> syncList<T>({
    required String boxName,
    required String scope,
    required Iterable<T> items,
    required CacheIdOf<T> idOf,
    required CacheJsonOf<T> toJson,
    bool deleteMissing = true,
  }) async {
    if (!_initialized) return false;
    final Box box = Hive.box(boxName);
    final Map<String, dynamic> bucket = _stringMap(box.get(scope));
    final Map<String, dynamic> existing = _stringMap(bucket[_recordsKey]);
    final Map<String, dynamic> next = Map<String, dynamic>.from(existing);
    final List<String> order = <String>[];
    bool changed = false;

    for (final T item in items) {
      final Object? id = idOf(item);
      if (id == null || id.toString().isEmpty) continue;
      final String key = id.toString();
      order.add(key);
      final Map<String, dynamic> json = toJson(item);
      if (!_deepEquals(existing[key], json)) {
        next[key] = json;
        changed = true;
      }
    }

    if (deleteMissing) {
      final Set<String> incoming = order.toSet();
      for (final String key in existing.keys.toList(growable: false)) {
        if (!incoming.contains(key)) {
          next.remove(key);
          changed = true;
        }
      }
    }

    if (!_listEquals(_stringList(bucket[_orderKey]), order)) changed = true;
    if (!changed) return false;

    await box.put(scope, <String, dynamic>{
      _recordsKey: next,
      _orderKey: order,
      _metaKey: <String, dynamic>{
        'cached_at': DateTime.now().toIso8601String(),
        'user_scope': userScope,
      },
    });
    return true;
  }

  Future<bool> syncItem({
    required String boxName,
    required String key,
    required Map<String, dynamic> json,
  }) async {
    if (!_initialized) return false;
    final Box box = Hive.box(boxName);
    if (_deepEquals(box.get(key), json)) return false;
    await box.put(key, json);
    return true;
  }

  String get userScope {
    final String token = AppSettings().tokenModel.accessToken ?? '';
    if (token.isEmpty) return 'guest';
    return token.hashCode.toUnsigned(32).toRadixString(16);
  }

  static Map<String, dynamic> _stringMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<String> _stringList(Object? value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const <String>[];
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _deepEquals(Object? a, Object? b) =>
      _canonical(a) == _canonical(b);

  static String _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((e) => e.toString()).toList()..sort();
      return '{${keys.map((key) => '$key:${_canonical(value[key])}').join(',')}}';
    }
    if (value is List) return '[${value.map(_canonical).join(',')}]';
    return value?.toString() ?? 'null';
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/progress.dart';

/// Offline-first persistence: the whole user state is stored locally as JSON.
class ProgressRepository {
  ProgressRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'cyberpath.progress.v1';

  UserProgress load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return UserProgress.initial();
    try {
      return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProgress.initial(); // corrupted data never crashes the app
    }
  }

  Future<void> save(UserProgress p) => _prefs.setString(_key, jsonEncode(p.toJson()));

  Future<void> clear() => _prefs.remove(_key);
}

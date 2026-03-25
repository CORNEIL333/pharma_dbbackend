import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _keySession = 'session_info';
  static const String _keyHistory = 'scan_history';

  Future<void> saveSession(SessionInfo session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySession, jsonEncode(session.toMap()));
  }

  Future<SessionInfo?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySession);
    if (data == null) return null;
    return SessionInfo.fromMap(jsonDecode(data));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySession);
  }

  Future<void> saveHistory(List<VisiteRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    final data = history.map((e) => e.toMap()).toList();
    await prefs.setString(_keyHistory, jsonEncode(data));
  }

  Future<List<VisiteRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyHistory);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => VisiteRecord.fromMap(e)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }
}

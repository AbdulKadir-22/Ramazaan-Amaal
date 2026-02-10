import 'package:hive_flutter/hive_flutter.dart';

import 'package:ramazaan_tracker/features/home/models/daily_record.dart';

class StorageService {
  static const String _boxName = 'userBox';
  static const String _dailyBoxName = 'dailyRecords';
  static const String _userNameKey = 'userName';

  // Initialize Hive (Call this in main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DailyRecordAdapter());
    await Hive.openBox(_boxName);
    await Hive.openBox<DailyRecord>(_dailyBoxName);
  }

  // Get the opened box
  Box get _box => Hive.box(_boxName);

  // Save User Name
  Future<void> saveUserName(String name) async {
    await _box.put(_userNameKey, name);
  }

  // Get User Name (Returns null if not found)
  String? getUserName() {
    return _box.get(_userNameKey);
  }

  // Check if user exists
  bool get hasUser => _box.containsKey(_userNameKey);

  // Daily Records
  Box<DailyRecord> get _dailyBox => Hive.box<DailyRecord>(_dailyBoxName);

  DailyRecord? getDailyRecord(DateTime date) {
    // Key format: YYYY-MM-DD
    final key = date.toIso8601String().split('T')[0];
    return _dailyBox.get(key);
  }

  Future<void> saveDailyRecord(DailyRecord record) async {
    final key = record.date.toIso8601String().split('T')[0];
    await _dailyBox.put(key, record);
  }
}
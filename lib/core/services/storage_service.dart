import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'userBox';
  static const String _userNameKey = 'userName';

  // Initialize Hive (Call this in main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
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
}
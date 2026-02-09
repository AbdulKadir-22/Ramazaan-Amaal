import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DailyProgressProvider extends ChangeNotifier {
  final Box _box = Hive.box('userBox'); // Using the box opened in main.dart
  
  // Helper to get today's key string (e.g., "2024-03-12")
  String get _todayKey => DateTime.now().toIso8601String().split('T')[0];

  // --- Suhoor Niyat ---
  bool get isSuhoorDone => _box.get('${_todayKey}_suhoor', defaultValue: false);

  void toggleSuhoor() {
    bool current = isSuhoorDone;
    _box.put('${_todayKey}_suhoor', !current);
    notifyListeners();
  }

  // --- Extra Salah (Tahajjud, Ishraq, etc.) ---
  bool isExtraSalahDone(String name) => _box.get('${_todayKey}_extra_$name', defaultValue: false);

  void toggleExtraSalah(String name) {
    bool current = isExtraSalahDone(name);
    _box.put('${_todayKey}_extra_$name', !current);
    notifyListeners();
  }

  // --- Main Salah ---
  // Returns true if the "Complete for Today" button was pressed for this prayer
  bool isSalahCompleted(String name) => _box.get('${_todayKey}_salah_$name', defaultValue: false);

  void setSalahCompleted(String name, bool status) {
    _box.put('${_todayKey}_salah_$name', status);
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:ramazaan_tracker/core/services/storage_service.dart';
import 'package:ramazaan_tracker/features/home/models/daily_record.dart';

class DailyProgressProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  late DailyRecord _todayRecord;

  // Initialize with empty to avoid null check issues before loading
  DailyProgressProvider() {
    _todayRecord = DailyRecord.empty(DateTime.now());
  }

  Future<void> loadDailyProgress() async {
    final now = DateTime.now();
    _todayRecord = _storage.getDailyRecord(now) ?? DailyRecord.empty(now);
    notifyListeners();
  }

  // --- Suhoor Niyat ---
  bool get isSuhoorDone => _todayRecord.suhoorNiyat;

  void toggleSuhoor() {
    _todayRecord.suhoorNiyat = !_todayRecord.suhoorNiyat;
    _saveProgress();
  }

  // --- Extra Salah (Tahajjud, Ishraq, etc.) ---
  bool isExtraSalahDone(String name) => _todayRecord.extraSalah[name] ?? false;

  void toggleExtraSalah(String name) {
    bool current = isExtraSalahDone(name);
    _todayRecord.extraSalah[name] = !current;
    _saveProgress();
  }

  // --- Main Salah ---
  bool isSalahCompleted(String name) => _todayRecord.salah[name] ?? false;

  void setSalahCompleted(String name, bool status) {
    _todayRecord.salah[name] = status;
    _saveProgress();
  }

  // --- Daily Reflection ---
  bool isReflectionDone(String name) => _todayRecord.selfReflection[name] ?? false;

  void toggleReflection(String name) {
    bool current = isReflectionDone(name);
    _todayRecord.selfReflection[name] = !current;
    _saveProgress();
  }
  
  void _saveProgress() {
    if (_todayRecord.isInBox) {
      _todayRecord.save();
    } else {
      _storage.saveDailyRecord(_todayRecord);
    }
    notifyListeners();
  }
}
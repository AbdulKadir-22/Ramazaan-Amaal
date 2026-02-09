import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/notification_service.dart';

class ZikrProvider extends ChangeNotifier {
  final Box _box = Hive.box('userBox');
  final NotificationService _notificationService = NotificationService();
  
  List<Map<String, dynamic>> _zikrList = [];

  List<Map<String, dynamic>> get zikrList => _zikrList;

  // Load data and handle daily reset
  void loadZikrData() {
    final rawList = _box.get('zikr_list', defaultValue: []);
    _zikrList = List<Map<String, dynamic>>.from(rawList.map((e) => Map<String, dynamic>.from(e)));
    
    _checkDailyReset();
    notifyListeners();
  }

  void _checkDailyReset() {
    final String today = DateTime.now().toIso8601String().split('T')[0];
    bool needsSave = false;

    for (var zikr in _zikrList) {
      if (zikr['lastUpdatedDate'] != today) {
        zikr['currentCount'] = 0; // Reset count
        zikr['lastUpdatedDate'] = today;
        needsSave = true;
      }
    }

    if (needsSave) _saveToHive();
  }

  Future<void> addZikr(String name, int target) async {
    final newZikr = {
      'id': const Uuid().v4(),
      'name': name,
      'currentCount': 0,
      'targetCount': target,
      'reminderTime': null,
      'lastUpdatedDate': DateTime.now().toIso8601String().split('T')[0],
    };

    _zikrList.add(newZikr);
    await _saveToHive();
    notifyListeners();
  }

  Future<void> updateCount(String id, int newCount) async {
    final index = _zikrList.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      _zikrList[index]['currentCount'] = newCount;
      _zikrList[index]['lastUpdatedDate'] = DateTime.now().toIso8601String().split('T')[0];
      await _saveToHive();
      notifyListeners();
    }
  }

  Future<void> updateReminder(String id, TimeOfDay time) async {
    final index = _zikrList.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      // 1. Save time string
      final timeString = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      _zikrList[index]['reminderTime'] = timeString;
      
      // 2. Schedule Notification (Use ID hashcode for unique notification ID)
      await _notificationService.scheduleDailyNotification(
        id: id.hashCode, 
        title: "Zikr Reminder",
        body: "Time for your ${_zikrList[index]['name']} zikr.",
        time: time,
      );

      await _saveToHive();
      notifyListeners();
    }
  }

  Future<void> deleteZikr(String id) async {
    // Cancel notification if exists
    await _notificationService.cancelNotification(id.hashCode);
    
    _zikrList.removeWhere((element) => element['id'] == id);
    await _saveToHive();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    await _box.put('zikr_list', _zikrList);
  }
}
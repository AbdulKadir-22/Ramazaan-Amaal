import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/notification_service.dart';

class ZikrProvider extends ChangeNotifier {
  // Ensure you opened this box in main.dart before using it here
  final Box _box = Hive.box('userBox'); 
  final NotificationService _notificationService = NotificationService();
  
  List<Map<String, dynamic>> _zikrList = [];

  List<Map<String, dynamic>> get zikrList => _zikrList;

  // --- 1. Load Data ---
  void loadZikrData() {
    final rawList = _box.get('zikr_list', defaultValue: []);
    // distinct conversion to ensure type safety
    _zikrList = List<Map<String, dynamic>>.from(
      rawList.map((e) => Map<String, dynamic>.from(e))
    );
    
    _checkDailyReset();
    notifyListeners();
  }

  // --- 2. Daily Reset Logic ---
  void _checkDailyReset() {
    final String today = DateTime.now().toIso8601String().split('T')[0];
    bool needsSave = false;

    for (var zikr in _zikrList) {
      // Check if lastUpdated exists, if not, set it to today
      String lastDate = zikr['lastUpdatedDate'] ?? today;

      if (lastDate != today) {
        zikr['currentCount'] = 0; // Reset count
        zikr['lastUpdatedDate'] = today;
        needsSave = true;
      }
    }

    if (needsSave) _saveToHive();
  }

  // --- 3. Add Zikr ---
  Future<void> addZikr(String name, int target) async {
    final newZikr = {
      'id': const Uuid().v4(),
      'name': name,
      'currentCount': 0,
      'targetCount': target,
      'reminderTime': null, // Stored as "HH:MM" string or null
      'lastUpdatedDate': DateTime.now().toIso8601String().split('T')[0],
    };

    _zikrList.add(newZikr);
    await _saveToHive();
    notifyListeners();
  }

  // --- 4. UPDATE ZIKR (The Missing Method!) ---
  // This is required by ZikrDetailScreen to save edits
  Future<void> updateZikr(String id, String newName, int newTarget, int newCount, String? newReminder) async {
    final index = _zikrList.indexWhere((element) => element['id'] == id);
    
    if (index != -1) {
      _zikrList[index]['name'] = newName;
      _zikrList[index]['targetCount'] = newTarget;
      _zikrList[index]['currentCount'] = newCount;
      _zikrList[index]['reminderTime'] = newReminder;
      _zikrList[index]['lastUpdatedDate'] = DateTime.now().toIso8601String().split('T')[0];

      // Handle Notification Logic
      if (newReminder != null && newReminder.isNotEmpty) {
        // Parse "HH:MM" string back to TimeOfDay
        final parts = newReminder.split(':');
        final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        
        if (_box.get('zikr_enabled', defaultValue: true)) {
          await _notificationService.scheduleDailyNotification(
            id: id.hashCode, 
            title: "📿 Zikr Reminder",
            body: "It's time for your $newName Amaal.",
            time: time,
            channelId: 'zikr_reminders',
            channelName: 'Zikr Reminders',
          );
        }
      } else {
        // If reminder was removed, cancel the notification
        await _notificationService.cancelNotification(id.hashCode);
      }

      await _saveToHive();
      notifyListeners();
    }
  }

  // --- 5. Quick Update Count (For List Screen) ---
  Future<void> updateCount(String id, int newCount) async {
    final index = _zikrList.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      _zikrList[index]['currentCount'] = newCount;
      _zikrList[index]['lastUpdatedDate'] = DateTime.now().toIso8601String().split('T')[0];
      await _saveToHive();
      notifyListeners();
    }
  }

  // --- 6. Update Reminder Only ---
  Future<void> updateReminder(String id, TimeOfDay time) async {
    final index = _zikrList.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      final timeString = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      _zikrList[index]['reminderTime'] = timeString;
      
      if (_box.get('zikr_enabled', defaultValue: true)) {
        await _notificationService.scheduleDailyNotification(
          id: id.hashCode, 
          title: "📿 Zikr Reminder",
          body: "Time for your ${_zikrList[index]['name']} Amaal.",
          time: time,
          channelId: 'zikr_reminders',
          channelName: 'Zikr Reminders',
        );
      }

      await _saveToHive();
      notifyListeners();
    }
  }

  // --- 7. Delete ---
  Future<void> deleteZikr(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    _zikrList.removeWhere((element) => element['id'] == id);
    await _saveToHive();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    await _box.put('zikr_list', _zikrList);
  }
}
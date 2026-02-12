import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/notification_service.dart';

class TilawatProvider extends ChangeNotifier {
  final Box _box = Hive.box('userBox');
  final NotificationService _notificationService = NotificationService();

  // We store a list of logs. Each log is a Map:
  // {
  //   'id': String,
  //   'date': String (ISO8601),
  //   'juz': int,
  //   'pages': int,
  // }
  List<Map<String, dynamic>> _tilawatLogs = [];

  List<Map<String, dynamic>> get tilawatLogs => _tilawatLogs;

  // --- Derived Stats (Calculated from logs) ---

  int get totalPagesRead {
    return _tilawatLogs.fold(0, (sum, item) => sum + (item['pages'] as int));
  }

  int get currentJuz {
    if (_tilawatLogs.isEmpty) return 1;
    // Return the juz from the most recent log
    return _tilawatLogs.first['juz'] as int;
  }

  double get progressPercentage {
    // Assuming standard 604 pages in Quran
    if (totalPagesRead == 0) return 0.0;
    return (totalPagesRead / 604).clamp(0.0, 1.0);
  }

  // --- Actions ---

  void loadTilawatData() {
    final rawList = _box.get('tilawat_history', defaultValue: []);
    
    // Convert to strongly typed List<Map>
    _tilawatLogs = List<Map<String, dynamic>>.from(
      rawList.map((e) => Map<String, dynamic>.from(e))
    );

    // Sort: Newest first
    _tilawatLogs.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA); 
    });

    notifyListeners();
  }

  Future<void> addLog(int juz, int pages) async {
    final newLog = {
      'id': const Uuid().v4(),
      'date': DateTime.now().toIso8601String(),
      'juz': juz,
      'pages': pages,
    };

    // Add to top of list
    _tilawatLogs.insert(0, newLog);
    
    await _saveToHive();
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    _tilawatLogs.removeWhere((element) => element['id'] == id);
    await _saveToHive();
    notifyListeners();
  }

  // Reminder Logic (Similar to your ZikrProvider)
  Future<void> setTilawatReminder(TimeOfDay time) async {
    // We use a fixed ID for Tilawat reminder to overwrite previous ones
    if (_box.get('tilawat_enabled', defaultValue: true)) {
      await _notificationService.scheduleDailyNotification(
        id: NotificationService.ID_TILAWAT,
        title: "📖 Time for Tilawat",
        body: "Keep going! Read a few pages of the Holy Qur'an to stay on track.",
        time: time,
        channelId: 'tilawat_reminders',
        channelName: 'Tilawat Reminders',
      );
    }
    
    // Save preference
    await _box.put('tilawat_reminder_time', '${time.hour}:${time.minute.toString().padLeft(2, '0')}');
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    await _box.put('tilawat_history', _tilawatLogs);
  }
}
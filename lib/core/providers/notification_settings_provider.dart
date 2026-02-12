import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/notification_service.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  final Box _box = Hive.box('userBox');
  final NotificationService _notificationService = NotificationService();

  bool _dailyReportEnabled = true;
  bool _salahEnabled = true;
  bool _tilawatEnabled = true;
  bool _zikrEnabled = true;

  bool get dailyReportEnabled => _dailyReportEnabled;
  bool get salahEnabled => _salahEnabled;
  bool get tilawatEnabled => _tilawatEnabled;
  bool get zikrEnabled => _zikrEnabled;

  void loadSettings() {
    _dailyReportEnabled = _box.get('daily_report_enabled', defaultValue: true);
    _salahEnabled = _box.get('salah_enabled', defaultValue: true);
    _tilawatEnabled = _box.get('tilawat_enabled', defaultValue: true);
    _zikrEnabled = _box.get('zikr_enabled', defaultValue: true);
    
    // Ensure 10 PM notification is scheduled if enabled
    if (_dailyReportEnabled) {
      _notificationService.scheduleDailyReportNotification();
    }
    
    notifyListeners();
  }

  Future<void> setDailyReportEnabled(bool value) async {
    _dailyReportEnabled = value;
    await _box.put('daily_report_enabled', value);
    
    if (value) {
      await _notificationService.scheduleDailyReportNotification();
    } else {
      await _notificationService.cancelNotification(NotificationService.ID_DAILY_REPORT);
    }
    
    notifyListeners();
  }

  Future<void> setSalahEnabled(bool value) async {
    _salahEnabled = value;
    await _box.put('salah_enabled', value);
    
    if (value) {
      // Re-schedule all set prayer times
      final times = _box.get('prayer_reminder_times', defaultValue: {});
      final prayerTimes = Map<String, String?>.from(times);
      
      final idMap = {
        'Fajr': NotificationService.ID_FAJR,
        'Dhuhr': NotificationService.ID_DHUHR,
        'Asr': NotificationService.ID_ASR,
        'Maghrib': NotificationService.ID_MAGHRIB,
        'Isha': NotificationService.ID_ISHA,
        'Taraweeh': NotificationService.ID_TARAWEEH,
      };

      for (var entry in prayerTimes.entries) {
        if (entry.value != null) {
          final parts = entry.value!.split(':');
          final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          await _notificationService.scheduleDailyNotification(
            id: idMap[entry.key] ?? entry.key.hashCode,
            title: "Prayer Reminder: ${entry.key}",
            body: "It's time for ${entry.key} prayer. Don't forget to record it!",
            time: time,
            channelId: 'prayer_reminders',
            channelName: 'Prayer Reminders',
          );
        }
      }
    } else {
      // Cancel all prayer notifications
      final ids = [
        NotificationService.ID_FAJR,
        NotificationService.ID_DHUHR,
        NotificationService.ID_ASR,
        NotificationService.ID_MAGHRIB,
        NotificationService.ID_ISHA,
        NotificationService.ID_TARAWEEH,
      ];
      for (var id in ids) {
        await _notificationService.cancelNotification(id);
      }
    }
    
    notifyListeners();
  }

  Future<void> setTilawatEnabled(bool value) async {
    _tilawatEnabled = value;
    await _box.put('tilawat_enabled', value);
    
    if (value) {
      final timeStr = _box.get('tilawat_reminder_time');
      if (timeStr != null) {
        final parts = timeStr.split(':');
        final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        await _notificationService.scheduleDailyNotification(
          id: NotificationService.ID_TILAWAT,
          title: "📖 Time for Tilawat",
          body: "Keep going! Read a few pages of the Holy Qur'an to stay on track.",
          time: time,
          channelId: 'tilawat_reminders',
          channelName: 'Tilawat Reminders',
        );
      }
    } else {
      await _notificationService.cancelNotification(NotificationService.ID_TILAWAT);
    }
    
    notifyListeners();
  }

  Future<void> setZikrEnabled(bool value) async {
    _zikrEnabled = value;
    await _box.put('zikr_enabled', value);
    
    final zikrListRaw = _box.get('zikr_list', defaultValue: []);
    final zikrList = List<Map<String, dynamic>>.from(zikrListRaw.map((e) => Map<String, dynamic>.from(e)));

    if (value) {
      // Re-schedule all Zikr notifications
      for (var zikr in zikrList) {
        final reminderTime = zikr['reminderTime'];
        if (reminderTime != null && reminderTime.isNotEmpty) {
          final parts = reminderTime.split(':');
          final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          await _notificationService.scheduleDailyNotification(
            id: zikr['id'].hashCode, 
            title: "📿 Zikr Reminder",
            body: "Time for your ${zikr['name']} Amaal.",
            time: time,
            channelId: 'zikr_reminders',
            channelName: 'Zikr Reminders',
          );
        }
      }
    } else {
      // Cancel all Zikr notifications
      for (var zikr in zikrList) {
        final id = zikr['id'];
        if (id != null) {
          await _notificationService.cancelNotification(id.hashCode);
        }
      }
    }
    
    notifyListeners();
  }
}

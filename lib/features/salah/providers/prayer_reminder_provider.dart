import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';

class PrayerReminderProvider extends ChangeNotifier {
  final Box _box = Hive.box('userBox');
  final NotificationService _notificationService = NotificationService();

  Map<String, String?> _prayerTimes = {};

  Map<String, String?> get prayerTimes => _prayerTimes;

  void loadTimes() {
    final times = _box.get('prayer_reminder_times', defaultValue: {});
    _prayerTimes = Map<String, String?>.from(times);
    notifyListeners();
  }

  String? getReminderTime(String prayerName) {
    return _prayerTimes[prayerName];
  }

  Future<void> setReminder(String prayerName, TimeOfDay time) async {
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    _prayerTimes[prayerName] = timeStr;
    await _box.put('prayer_reminder_times', _prayerTimes);

    final idMap = {
      'Fajr': NotificationService.ID_FAJR,
      'Dhuhr': NotificationService.ID_DHUHR,
      'Asr': NotificationService.ID_ASR,
      'Maghrib': NotificationService.ID_MAGHRIB,
      'Isha': NotificationService.ID_ISHA,
      'Taraweeh': NotificationService.ID_TARAWEEH,
    };

    if (_box.get('salah_enabled', defaultValue: true)) {
      await _notificationService.scheduleDailyNotification(
        id: idMap[prayerName] ?? prayerName.hashCode,
        title: "Prayer Reminder: $prayerName",
        body: "It's time for $prayerName prayer. Don't forget to record it!",
        time: time,
        channelId: 'prayer_reminders',
        channelName: 'Prayer Reminders',
      );
    }

    notifyListeners();
  }

  Future<void> cancelReminder(String prayerName) async {
    _prayerTimes.remove(prayerName);
    await _box.put('prayer_reminder_times', _prayerTimes);

    final idMap = {
      'Fajr': NotificationService.ID_FAJR,
      'Dhuhr': NotificationService.ID_DHUHR,
      'Asr': NotificationService.ID_ASR,
      'Maghrib': NotificationService.ID_MAGHRIB,
      'Isha': NotificationService.ID_ISHA,
      'Taraweeh': NotificationService.ID_TARAWEEH,
    };

    await _notificationService.cancelNotification(idMap[prayerName] ?? prayerName.hashCode);
    notifyListeners();
  }
}

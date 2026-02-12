import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import '../services/storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int ID_DAILY_REPORT = 1000;
  static const int ID_TILAWAT = 999;
  static const int ID_FAJR = 101;
  static const int ID_DHUHR = 102;
  static const int ID_ASR = 103;
  static const int ID_MAGHRIB = 104;
  static const int ID_ISHA = 105;
  static const int ID_TARAWEEH = 106;

  Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = timezoneInfo.identifier;
      
      debugPrint('DEBUG: Detected Timezone Identifier: $timeZoneName');
      
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        // More aggressive fallback for India specifically as it's a common fail point
        if (timeZoneName == 'Asia/Calcutta' || timeZoneName.contains('India')) {
          tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        } else if (timeZoneName.contains('Karachi')) {
          tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
        } else {
          debugPrint('DEBUG: Falling back to UTC due to: $e');
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      }
      debugPrint('DEBUG: Effective Timezone: ${tz.local.name}');
    } catch (e) {
      debugPrint('DEBUG: Fatal Timezone Error: $e');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Initialize Firebase and FCM
    await _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      // In a real app, you'd need the google-services.json/GoogleService-Info.plist properly set up
      await Firebase.initializeApp();
      
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request FCM permissions (mostly for iOS)
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM Token
      debugPrint('DEBUG: Waiting a moment for Firebase services to warm up...');
      await Future.delayed(const Duration(seconds: 2));
      
      debugPrint('DEBUG: Attempting to get FCM Token...');
      String? token = await messaging.getToken();
      debugPrint('DEBUG: FCM Token retrieved: ${token != null ? "YES" : "NO"}');
      if (token != null) debugPrint('DEBUG: Token: $token');

      if (token != null) {
        final storage = StorageService();
        final name = storage.getUserName() ?? "Unknown User";
        debugPrint('DEBUG: Registering device for user: $name');
        
        // Register token with backend
        await ApiService().registerDevice(name: name, token: token);
        debugPrint('DEBUG: Device registered successfully with backend');
      } else {
        debugPrint('DEBUG: Token is null, skipping registration');
      }

      // Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        if (message.notification != null) {
          showNotification(
            id: DateTime.now().millisecond,
            title: message.notification!.title ?? 'Notification',
            body: message.notification!.body ?? '',
          );
        }
      });

      // Handle Background/Terminated Messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
    } catch (e) {
      debugPrint('DEBUG: Firebase/FCM error: $e. (This is expected if Firebase is not fully configured yet)');
    }
  }

  Future<Map<String, String>> getInternalInfo() async {
    return {
      'timezone_plugin': await FlutterTimezone.getLocalTimezone().then((v) => v.identifier).catchError((e) => 'Error: $e'),
      'tz_local_name': tz.local.name,
      'system_now': DateTime.now().toString(),
      'tz_now': tz.TZDateTime.now(tz.local).toString(),
    };
  }

  Future<void> requestPermissions() async {
    // Android 13+ requires explicit notification permission
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      // This is the crucial one for Android 12+. Guide user if it fails.
      await androidPlugin.requestExactAlarmsPermission();
    }

    // iOS permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String channelId = 'ramazan_reminders_v1',
    String channelName = 'Reminders',
  }) async {
    // 1. Get current system time (most reliable reference)
    final systemNow = DateTime.now();
    
    // 2. Build the target date/time for TODAY using system components
    DateTime targetDateTime = DateTime(
      systemNow.year,
      systemNow.month,
      systemNow.day,
      time.hour,
      time.minute,
    );

    // 3. If target is in the past, move it to tomorrow
    if (targetDateTime.isBefore(systemNow)) {
      targetDateTime = targetDateTime.add(const Duration(days: 1));
    }

    // 4. Convert to TZDateTime for the plugin
    final scheduledDate = tz.TZDateTime.from(targetDateTime, tz.local);

    debugPrint('DEBUG: Scheduling $title for $scheduledDate (System: $targetDateTime)');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
          // Ensure it can wake the device
          fullScreenIntent: false,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyReportNotification() async {
    await scheduleDailyNotification(
      id: ID_DAILY_REPORT,
      title: "📊 Your Daily Report is Here",
      body: "Check your progress before you sleep! How was your day today?",
      time: const TimeOfDay(hour: 22, minute: 0),
      channelId: 'daily_report_reminders',
      channelName: 'Daily Report Reminders',
    );
  }

  /// Schedules a test notification using a completely different strategy
  Future<void> scheduleTestNotification() async {
    final systemNow = DateTime.now();
    final targetDateTime = systemNow.add(const Duration(seconds: 5));
    final scheduledDate = tz.TZDateTime.from(targetDateTime, tz.local);

    debugPrint('DEBUG: Simple 5s Test for $scheduledDate');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      '🎯 Quick Test (5s)',
      'Scheduled via Time-Bridging strategy.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel_v2',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleTestInexactNotification() async {
    final systemNow = DateTime.now();
    final targetDateTime = systemNow.add(const Duration(seconds: 10));
    final scheduledDate = tz.TZDateTime.from(targetDateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      888,
      '🧪 Inexact Test (10s)',
      'This avoids strict system rules.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel_v2',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'immediate_notifications',
    String channelName = 'Immediate Notifications',
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.media.app.NotificationCompat** { *; }

# Hive rules
-keep class io.hive.** { *; }
-keepnames class io.hive.** { *; }
-keep class * extends io.hive.TypeAdapter { *; }
-keep class * extends io.hive.HiveObject { *; }
-keep @io.hive.HiveType class * { *; }
-keepclassmembers class * {
    @io.hive.HiveField *;
}

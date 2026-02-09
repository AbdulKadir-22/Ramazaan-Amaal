import 'package:flutter/material.dart';

class PrayerUnit {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const PrayerUnit({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class PrayerData {
  // Static configuration for all prayers
  static final Map<String, List<PrayerUnit>> prayerStructure = {
    'Fajr': [
      PrayerUnit(title: "2 Sunnah", subtitle: "Before Farz", icon: Icons.wb_twilight, iconColor: const Color(0xFF81C784), iconBgColor: const Color(0xFFE8F5E9)),
      PrayerUnit(title: "2 Farz", subtitle: "Essential", icon: Icons.groups, iconColor: const Color(0xFF4DB6AC), iconBgColor: const Color(0xFFE0F2F1)),
    ],
    'Dhuhr': [
      PrayerUnit(title: "4 Sunnah", subtitle: "Before Farz", icon: Icons.wb_sunny_outlined, iconColor: const Color(0xFF7986CB), iconBgColor: const Color(0xFFE8EAF6)),
      PrayerUnit(title: "4 Farz", subtitle: "Essential", icon: Icons.groups, iconColor: const Color(0xFF4DB6AC), iconBgColor: const Color(0xFFE0F2F1)),
      PrayerUnit(title: "2 Sunnah", subtitle: "After Farz", icon: Icons.wb_sunny, iconColor: const Color(0xFF7986CB), iconBgColor: const Color(0xFFE8EAF6)),
      PrayerUnit(title: "2 Nafl", subtitle: "Optional", icon: Icons.favorite_border, iconColor: const Color(0xFF90A4AE), iconBgColor: const Color(0xFFECEFF1)),
    ],
    'Asr': [
      PrayerUnit(title: "4 Sunnah", subtitle: "Ghair Muakkada", icon: Icons.wb_sunny_outlined, iconColor: const Color(0xFF90A4AE), iconBgColor: const Color(0xFFECEFF1)),
      PrayerUnit(title: "4 Farz", subtitle: "Essential", icon: Icons.groups, iconColor: const Color(0xFF4DB6AC), iconBgColor: const Color(0xFFE0F2F1)),
    ],
    'Maghrib': [
      PrayerUnit(title: "3 Farz", subtitle: "Essential", icon: Icons.groups, iconColor: const Color(0xFF4DB6AC), iconBgColor: const Color(0xFFE0F2F1)),
      PrayerUnit(title: "2 Sunnah", subtitle: "After Farz", icon: Icons.nightlight_round, iconColor: const Color(0xFF7986CB), iconBgColor: const Color(0xFFE8EAF6)),
      PrayerUnit(title: "2 Nafl", subtitle: "Optional", icon: Icons.favorite_border, iconColor: const Color(0xFF90A4AE), iconBgColor: const Color(0xFFECEFF1)),
    ],
    'Isha': [
      PrayerUnit(title: "4 Sunnah", subtitle: "Ghair Muakkada", icon: Icons.nightlight_outlined, iconColor: const Color(0xFF90A4AE), iconBgColor: const Color(0xFFECEFF1)),
      PrayerUnit(title: "4 Farz", subtitle: "Essential", icon: Icons.groups, iconColor: const Color(0xFF4DB6AC), iconBgColor: const Color(0xFFE0F2F1)),
      PrayerUnit(title: "2 Sunnah", subtitle: "After Farz", icon: Icons.nightlight_round, iconColor: const Color(0xFF7986CB), iconBgColor: const Color(0xFFE8EAF6)),
      PrayerUnit(title: "3 Witr", subtitle: "Wajib", icon: Icons.star_rate_rounded, iconColor: const Color(0xFFAB47BC), iconBgColor: const Color(0xFFF3E5F5)),
    ],
    'Taraweeh': [
      PrayerUnit(title: "20 Rakats", subtitle: "Sunnah Muakkada", icon: Icons.mosque, iconColor: const Color(0xFF10B981), iconBgColor: const Color(0xFFE0F2F1)),
    ],
  };
}
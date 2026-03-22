import 'package:flutter/material.dart';

class DuaModel {
  final int id;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String category;
  final String iconName;
  final Color iconColor;
  final Color bgColor;

  DuaModel({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.category,
    required this.iconName,
    required this.iconColor,
    required this.bgColor,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'],
      title: json['title'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      category: json['category'],
      iconName: json['icon'],
      iconColor: Color(int.parse(json['iconColor'])),
      bgColor: Color(int.parse(json['bgColor'])),
    );
  }

  IconData get iconData {
    switch (iconName) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'restaurant_rounded':
        return Icons.restaurant_rounded;
      case 'restaurant_menu_rounded':
        return Icons.restaurant_menu_rounded;
      case 'home_rounded':
        return Icons.home_rounded;
      case 'exit_to_app_rounded':
        return Icons.exit_to_app_rounded;
      case 'clean_hands_rounded':
        return Icons.clean_hands_rounded;
      case 'spa_rounded':
        return Icons.spa_rounded;
      case 'opacity_rounded':
        return Icons.opacity_rounded;
      case 'done_all_rounded':
        return Icons.done_all_rounded;
      case 'mosque_rounded':
        return Icons.mosque_rounded;
      case 'directions_run_rounded':
        return Icons.directions_run_rounded;
      case 'shield_rounded':
        return Icons.shield_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'sentiment_satisfied_rounded':
        return Icons.sentiment_satisfied_rounded;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'health_and_safety_rounded':
        return Icons.health_and_safety_rounded;
      case 'directions_car_rounded':
        return Icons.directions_car_rounded;
      case 'flight_rounded':
        return Icons.flight_rounded;
      case 'help_outline_rounded':
        return Icons.help_outline_rounded;
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'family_restroom_rounded':
        return Icons.family_restroom_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'assignment_turned_in_rounded':
        return Icons.assignment_turned_in_rounded;
      case 'shopping_bag_rounded':
        return Icons.shopping_bag_rounded;
      case 'water_drop_rounded':
        return Icons.water_drop_rounded;
      case 'wb_cloudy_rounded':
        return Icons.wb_cloudy_rounded;
      case 'thunderstorm_rounded':
        return Icons.thunderstorm_rounded;
      case 'visibility_rounded':
        return Icons.visibility_rounded;
      case 'mood_bad_rounded':
        return Icons.mood_bad_rounded;
      case 'bedtime_rounded':
        return Icons.bedtime_rounded;
      case 'brightness_medium_rounded':
        return Icons.brightness_medium_rounded;
      case 'favorite_outline_rounded':
        return Icons.favorite_border_rounded;
      case 'auto_awesome_rounded':
        return Icons.auto_awesome_rounded;
      case 'local_fire_department_rounded':
        return Icons.local_fire_department_rounded;
      case 'location_on_rounded':
        return Icons.location_on_rounded;
      case 'groups_rounded':
        return Icons.groups_rounded;
      case 'public_rounded':
        return Icons.public_rounded;
      case 'anchor_rounded':
        return Icons.anchor_rounded;
      case 'villa_rounded':
        return Icons.villa_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}

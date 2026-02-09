import 'package:hive/hive.dart';
// import 'package:flutter/material.dart';

part 'zikr_model.g.dart'; // You will need to run build_runner or just use manual adapter if preferred

@HiveType(typeId: 1)
class ZikrItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int currentCount;

  @HiveField(3)
  int targetCount;

  @HiveField(4)
  String? reminderTime; // Stored as "HH:MM" string

  @HiveField(5)
  String lastUpdatedDate; // To handle daily resets

  ZikrItem({
    required this.id,
    required this.name,
    this.currentCount = 0,
    required this.targetCount,
    this.reminderTime,
    required this.lastUpdatedDate,
  });

  bool get isCompleted => currentCount >= targetCount;
}
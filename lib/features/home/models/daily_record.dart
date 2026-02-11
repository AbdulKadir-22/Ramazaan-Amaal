import 'package:hive/hive.dart';

part 'daily_record.g.dart';

@HiveType(typeId: 0)
class DailyRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final Map<String, bool> salah;

  @HiveField(2)
  final Map<String, bool> extraSalah;

  @HiveField(3)
  bool suhoorNiyat;

  @HiveField(4)
  int tilawatPages;
  
  @HiveField(6)
  final Map<String, bool> selfReflection;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  bool rozaNiyat;

  @HiveField(9)
  final Map<String, bool> duas;

  DailyRecord({
    required this.date,
    required this.salah,
    required this.extraSalah,
    this.suhoorNiyat = false,
    this.rozaNiyat = false,
    this.tilawatPages = 0,
    Map<String, bool>? selfReflection,
    Map<String, bool>? duas,
    this.notes,
  }) : selfReflection = selfReflection ?? {
          'Avoided Lying': false,
          'Avoided Backbiting': false,
          'Lowered Gaze': false,
          'Avoided Argument': false,
          'Controlled Negative Thoughts': false,
        },
        duas = duas ?? {};

  // Factory to create an empty record for a formatted date string
  factory DailyRecord.empty(DateTime date) {
    return DailyRecord(
      date: date,
      salah: {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
        'Taraweeh': false,
      },
      extraSalah: {
        'Tahajjud': false,
        'Ishraq': false,
        'Chasht': false,
        'Awwabin': false,
      },
      selfReflection: {
        'Avoided Lying': false,
        'Avoided Backbiting': false,
        'Lowered Gaze': false,
        'Avoided Argument': false,
        'Controlled Negative Thoughts': false,
      },
      notes: null,
      rozaNiyat: false,
      duas: {},
    );
  }
}

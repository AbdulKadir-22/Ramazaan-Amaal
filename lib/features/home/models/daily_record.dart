import 'package:hive/hive.dart';
import '../../../core/constants/app_constants.dart';

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

  @HiveField(10)
  final Map<String, int> zikr;

  DailyRecord({
    required this.date,
    required this.salah,
    required this.extraSalah,
    this.suhoorNiyat = false,
    this.rozaNiyat = false,
    this.tilawatPages = 0,
    Map<String, bool>? selfReflection,
    Map<String, bool>? duas,
    Map<String, int>? zikr,
    this.notes,
  }) : selfReflection = selfReflection ?? {
          AppConstants.reflectionLying: false,
          AppConstants.reflectionBackbiting: false,
          AppConstants.reflectionGaze: false,
          AppConstants.reflectionArgument: false,
          AppConstants.reflectionNegativeThoughts: false,
        },
        duas = duas ?? {},
        zikr = zikr ?? {};

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
        AppConstants.reflectionLying: false,
        AppConstants.reflectionBackbiting: false,
        AppConstants.reflectionGaze: false,
        AppConstants.reflectionArgument: false,
        AppConstants.reflectionNegativeThoughts: false,
      },
      notes: null,
      rozaNiyat: false,
      duas: {},
      zikr: {},
    );
  }
}

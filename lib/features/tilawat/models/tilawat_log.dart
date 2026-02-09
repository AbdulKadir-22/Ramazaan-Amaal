import 'package:hive/hive.dart';

part 'tilawat_log.g.dart'; // generated file

@HiveType(typeId: 1) // Ensure typeId is unique across your app
class TilawatLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int juzNumber;

  @HiveField(2)
  final int pagesRead;

  TilawatLog({
    required this.date,
    required this.juzNumber,
    required this.pagesRead,
  });
}
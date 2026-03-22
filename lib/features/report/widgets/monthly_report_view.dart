import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../home/models/daily_record.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/share_util.dart';
import 'package:screenshot/screenshot.dart';

class MonthlyReportView extends StatefulWidget {
  const MonthlyReportView({super.key});

  @override
  State<MonthlyReportView> createState() => _MonthlyReportViewState();
}

class _MonthlyReportViewState extends State<MonthlyReportView> {
  late Future<Map<String, dynamic>> _ramadanReportFuture;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _reFetch();
  }

  void _reFetch() {
    setState(() {
      _ramadanReportFuture = _fetchMonthlyReportData();
    });
  }

  Future<Map<String, dynamic>> _fetchMonthlyReportData() async {
    final now = DateTime.now();
    final hijriNow = HijriCalendar.now();
    final targetMonth = hijriNow.hMonth;
    
    // We want to find the range of the current Hijri month progress
    List<DailyRecord> records = [];
    
    // Look back up to 40 days to find all records of the target Hijri month
    for (int i = 0; i < 40; i++) {
        final date = now.subtract(Duration(days: i));
        final hDate = HijriCalendar.fromDate(date);
        
        if (hDate.hMonth == targetMonth) {
            final record = _storage.getDailyRecord(date);
            if (record != null) {
                records.add(record);
            }
        } else if (records.isNotEmpty) {
            // Stop if we found relevant records and are now crossing into a different month
            break; 
        }
    }

    // Aggregation
    int totalTilawat = records.fold(0, (sum, r) => sum + r.tilawatPages);
    int totalDuas = records.fold(0, (sum, r) {
      int count = 0;
      r.duas.forEach((k, v) { if (v) count++; });
      return sum + count;
    });
    
    // Salah
    Map<String, int> salahCounts = {
      'Fajr': 0, 'Dhuhr': 0, 'Asr': 0, 'Maghrib': 0, 'Isha': 0, 'Taraweeh': 0
    };
    int totalNawafil = 0;
    
    // Reflection/Habits
    Map<String, int> habitCounts = {
      for (var key in AppConstants.reflectionKeys) key: 0,
    };
    
    // Zikr
    Map<String, int> zikrTotals = {};
    
    List<String> allNotes = [];

    for (var r in records) {
      r.salah.forEach((key, value) {
        if (value && salahCounts.containsKey(key)) {
          salahCounts[key] = (salahCounts[key] ?? 0) + 1;
        }
      });
      
      r.extraSalah.forEach((key, value) {
        if (value) totalNawafil++;
      });
      
      r.selfReflection.forEach((key, value) {
        if (value && habitCounts.containsKey(key)) {
          habitCounts[key] = (habitCounts[key] ?? 0) + 1;
        }
      });
      
      r.zikr.forEach((key, value) {
        zikrTotals[key] = (zikrTotals[key] ?? 0) + value;
      });
      
      if (r.notes != null && r.notes!.trim().isNotEmpty) {
        allNotes.add("${DateFormat('d MMM').format(r.date)}: ${r.notes}");
      }
    }

    return {
      'records': records,
      'totalTilawat': totalTilawat,
      'salahCounts': salahCounts,
      'totalNawafil': totalNawafil,
      'habitCounts': habitCounts,
      'zikrTotals': zikrTotals,
      'allNotes': allNotes,
      'daysTracked': records.length,
      'totalDuas': totalDuas,
    };
  }

  void _shareReport(Map<String, dynamic> data) async {
    final title = "Monthly";
    final text = "My $title Progress so far:\n"
                 "Tilawat: ${data['totalTilawat']} Pages\n"
                 "Salah Consistency: ${data['salahCounts']['Fajr']}/${data['daysTracked']} Fajr, etc.\n"
                 "Tracked with ${AppConstants.appName}.";
    
    try {
      final uint8list = await ShareUtil.screenshotController.capture();
      if (uint8list != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/monthly_report_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(uint8list);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: text,
        );
      } else {
        await ShareUtil.shareText(text);
      }
    } catch (e) {
      debugPrint('Error sharing monthly report: $e');
      await ShareUtil.shareText(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _ramadanReportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text("Error loading data: ${snapshot.error}", textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null || (data['records'] as List).isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  const Text("No Monthly records found yet.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text("Start tracking your Monthly days!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        final records = List<DailyRecord>.from(data['records']);
        
        return Screenshot(
          controller: ShareUtil.screenshotController,
          child: Container(
            color: const Color(0xFFFDFAF6), // Match scaffold background
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Text(DateFormat('MMMM yyyy').format(DateTime.now()), 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildMainSummary(data),
                  const SizedBox(height: 24),
                  _buildDetailedStats(data),
                  const SizedBox(height: 24),
                  _buildZikrSummary(data['zikrTotals']),
                  const SizedBox(height: 24),
                  _buildHabitSummary(data['habitCounts'], data['daysTracked']),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareReport(data),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text("Share My Progress"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainSummary(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MONTHLY SUMMARY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryIconStat(Icons.menu_book_outlined, data['totalTilawat'].toString(), "TILAWAT (PG)"),
              _buildSummaryIconStat(Icons.auto_awesome_outlined, data['totalNawafil'].toString(), "NAWAFIL"),
              _buildSummaryIconStat(Icons.front_hand_outlined, data['totalDuas'].toString(), "DUAS"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryIconStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF1F8F6), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF4C8C74), size: 24),
        ),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailedStats(Map<String, dynamic> data) {
    final Map<String, int> salah = data['salahCounts'];
    final int days = data['daysTracked'];
    
    // Calculate overall average
    int totalPossible = days * 6; // 5 + Taraweeh
    int totalDone = 0;
    salah.forEach((_, v) => totalDone += v);
    int avg = totalPossible > 0 ? (totalDone / totalPossible * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Salah Consistency", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F8F6), borderRadius: BorderRadius.circular(20)),
                child: Text("$avg% Avg", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4C8C74))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSalahBars(salah, days),
        ],
      ),
    );
  }

  Widget _buildSalahBars(Map<String, int> counts, int totalDays) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Taraweeh'];
    return Column(
      children: prayers.map((p) {
        final count = counts[p] ?? 0;
        final progress = totalDays > 0 ? count / totalDays : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text("$count/$totalDays days", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryDark),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildZikrSummary(Map<String, int> zikrTotals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Zikr Recited", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 20),
          if (zikrTotals.isEmpty) 
            const Center(child: Text("No Zikr data yet", style: TextStyle(color: Colors.grey)))
          else
            ...zikrTotals.entries.map((e) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                      Text(NumberFormat('#,###').format(e.value), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF4C8C74))),
                    ],
                  ),
                ),
                if (e.key != zikrTotals.keys.last) const Divider(height: 1, color: Color(0xFFF5F5F5)),
              ],
            )),
        ],
      ),
    );
  }

  Widget _buildHabitSummary(Map<String, int> habitCounts, int totalDays) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Self Control & Habits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: habitCounts.entries.map((e) {
                final percentage = totalDays > 0 ? (e.value / totalDays * 100).toInt() : 0;
                String label = e.key;
                if (e.key == AppConstants.reflectionLying) label = "Avoided Lying";
                if (e.key == AppConstants.reflectionBackbiting) label = "Avoided Backbiting";
                if (e.key == AppConstants.reflectionGaze) label = "Lowered Gaze";
                if (e.key == AppConstants.reflectionArgument) label = "Avoided Argument";
                if (e.key == AppConstants.reflectionNegativeThoughts) label = "Controlled Thoughts";

                return SizedBox(
                  width: 90,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor: const AlwaysStoppedAnimation(AppColors.primaryDark),
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text("$percentage%", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, height: 1.2)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesFeed(List<String> notes) {
    if (notes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Journal Entries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
          ...notes.map((note) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.edit_note, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(note, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

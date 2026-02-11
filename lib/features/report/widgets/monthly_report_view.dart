import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../home/models/daily_record.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_colors.dart';
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
    int totalRoza = records.where((r) => r.rozaNiyat).length;
    int totalTilawat = records.fold(0, (sum, r) => sum + r.tilawatPages);
    
    // Salah
    Map<String, int> salahCounts = {
      'Fajr': 0, 'Dhuhr': 0, 'Asr': 0, 'Maghrib': 0, 'Isha': 0, 'Taraweeh': 0
    };
    int totalNawafil = 0;
    
    // Reflection/Habits
    Map<String, int> habitCounts = {
      'Avoided Lying': 0,
      'Avoided Backbiting': 0,
      'Lowered Gaze': 0,
      'Avoided Argument': 0,
      'Controlled Negative Thoughts': 0,
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
      'totalRoza': totalRoza,
      'totalTilawat': totalTilawat,
      'salahCounts': salahCounts,
      'totalNawafil': totalNawafil,
      'habitCounts': habitCounts,
      'zikrTotals': zikrTotals,
      'allNotes': allNotes,
      'daysTracked': records.length,
    };
  }

  void _shareReport(Map<String, dynamic> data) async {
    final isRamadan = HijriCalendar.now().hMonth == 9;
    final title = isRamadan ? "Ramadan" : "Monthly";
    final text = "My $title Progress so far:\n"
                 "Total Roza/Fast: ${data['totalRoza']}\n"
                 "Tilawat: ${data['totalTilawat']} Pages\n"
                 "Salah Consistency: ${data['salahCounts']['Fajr']}/${data['daysTracked']} Fajr, etc.\n"
                 "Tracked with Ramaz Amaal Tracker.";
    
    ShareUtil.shareText(text);
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
          final isRamadan = HijriCalendar.now().hMonth == 9;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  Text("No ${isRamadan ? 'Ramadan' : 'Monthly'} records found yet.", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("Start tracking your ${isRamadan ? 'Ramadan' : 'Monthly'} days!", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        final records = List<DailyRecord>.from(data['records']);
        
        return Column(
          children: [
            _buildMainSummary(data),
            const SizedBox(height: 20),
            _buildDetailedStats(data),
            const SizedBox(height: 20),
            _buildZikrSummary(data['zikrTotals']),
            const SizedBox(height: 20),
            _buildHabitSummary(data['habitCounts'], data['daysTracked']),
            const SizedBox(height: 20),
            _buildNotesFeed(data['allNotes']),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareReport(data),
                icon: const Icon(Icons.share, size: 18),
                label: Text("Share My ${HijriCalendar.now().hMonth == 9 ? 'Ramadan' : 'Monthly'} Journey"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildMainSummary(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(77), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLargeStat("Roza", data['totalRoza'].toString(), Icons.favorite),
              _buildLargeStat("Pages", data['totalTilawat'].toString(), Icons.menu_book),
              _buildLargeStat("Nawafil", data['totalNawafil'].toString(), Icons.auto_awesome),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Text(
            "Tracked for ${data['daysTracked']} days of ${HijriCalendar.now().hMonth == 9 ? 'Ramadan' : 'this Month'}",
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget _buildLargeStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailedStats(Map<String, dynamic> data) {
    final Map<String, int> salah = data['salahCounts'];
    final int days = data['daysTracked'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Salah Consistency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
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
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text("$count/$totalDays", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(progress == 1.0 ? const Color(0xFF10B981) : AppColors.primary),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildZikrSummary(Map<String, int> zikrTotals) {
    if (zikrTotals.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Zikr Recited", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
          ...zikrTotals.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(e.value.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHabitSummary(Map<String, int> habitCounts, int totalDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Self Control / Habits", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: habitCounts.entries.map((e) {
              final percentage = totalDays > 0 ? (e.value / totalDays * 100).toInt() : 0;
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation(percentage > 70 ? const Color(0xFF10B981) : AppColors.primary),
                          strokeWidth: 6,
                        ),
                      ),
                      Text("$percentage%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 70,
                    child: Text(e.key, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesFeed(List<String> notes) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final isRamadan = HijriCalendar.now().hMonth == 9;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${isRamadan ? 'Ramadan' : 'Monthly'} Journal Entries", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
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

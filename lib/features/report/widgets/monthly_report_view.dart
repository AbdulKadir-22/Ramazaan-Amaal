import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../home/models/daily_record.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_colors.dart';

class MonthlyReportView extends StatefulWidget {
  const MonthlyReportView({super.key});

  @override
  State<MonthlyReportView> createState() => _MonthlyReportViewState();
}

class _MonthlyReportViewState extends State<MonthlyReportView> {
  late Future<List<DailyRecord?>> _monthlyDataFuture;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _monthlyDataFuture = _fetchMonthlyData();
  }

  Future<List<DailyRecord?>> _fetchMonthlyData() async {
    // Fetch last 30 days
    final now = DateTime.now();
    List<DailyRecord?> records = [];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      records.add(_storage.getDailyRecord(date));
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyRecord?>>(
      future: _monthlyDataFuture,
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

        final records = snapshot.data ?? [];
        if (records.every((r) => r == null)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 48),
                  SizedBox(height: 16),
                  Text("No records found for this month yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        // Sort newest first
        final reversedRecords = records.reversed.where((r) => r != null).toList();
        
        return Column(
          children: [
            _buildSummaryStats(records),
            const SizedBox(height: 24),
            _buildHistoryList(reversedRecords),
          ],
        );
      },
    );
  }

  Widget _buildSummaryStats(List<DailyRecord?> records) {
    int validRecordsCount = records.where((r) => r != null).length;
    if (validRecordsCount == 0) return const SizedBox.shrink();

    int totalSalahPossible = validRecordsCount * 5;
    int totalFajr = 0, totalDhuhr = 0, totalAsr = 0, totalMaghrib = 0, totalIsha = 0;
    
    for (var r in records) {
      if (r != null) {
        if (r.salah['Fajr'] == true) totalFajr++;
        if (r.salah['Dhuhr'] == true) totalDhuhr++;
        if (r.salah['Asr'] == true) totalAsr++;
        if (r.salah['Maghrib'] == true) totalMaghrib++;
        if (r.salah['Isha'] == true) totalIsha++;
      }
    }
    
    int totalCompleted = totalFajr + totalDhuhr + totalAsr + totalMaghrib + totalIsha;
    String percentage = totalSalahPossible > 0 
        ? ((totalCompleted / totalSalahPossible) * 100).toStringAsFixed(1) 
        : "0";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Text("$percentage%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const Text("Salah Consistency (Active Days)", style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem("Fajr", totalFajr),
                const SizedBox(width: 16),
                _buildStatItem("Dhuhr", totalDhuhr),
                const SizedBox(width: 16),
                _buildStatItem("Asr", totalAsr),
                const SizedBox(width: 16),
                _buildStatItem("Maghrib", totalMaghrib),
                const SizedBox(width: 16),
                _buildStatItem("Isha", totalIsha),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHistoryList(List<DailyRecord?> reversedRecords) {
    return Column(
      children: reversedRecords.map((record) {
        if (record == null) return const SizedBox.shrink();
        
        int completedSalah = 0;
        if (record.salah['Fajr'] == true) completedSalah++;
        if (record.salah['Dhuhr'] == true) completedSalah++;
        if (record.salah['Asr'] == true) completedSalah++;
        if (record.salah['Maghrib'] == true) completedSalah++;
        if (record.salah['Isha'] == true) completedSalah++;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5, offset: const Offset(0, 2))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM').format(record.date), 
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)
                  ),
                  Row(
                    children: [
                      if (record.rozaNiyat) 
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: completedSalah == 5 ? AppColors.accent.withOpacity(0.2) : Colors.grey.shade100, 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(
                          "$completedSalah/5 Salah", 
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: completedSalah == 5 ? AppColors.primary : Colors.grey)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  record.notes!, 
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
}

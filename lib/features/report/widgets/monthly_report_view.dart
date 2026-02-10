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

  @override
  void initState() {
    super.initState();
    _monthlyDataFuture = _fetchMonthlyData();
  }

  Future<List<DailyRecord?>> _fetchMonthlyData() async {
    final storage = StorageService();
    // Fetch current month's data. For simplicity, let's just fetch last 30 days.
    // Or strictly "This Month" (e.g. March). 
    // Let's do last 30 days for rolling report which is often more useful.
    final now = DateTime.now();
    List<DailyRecord?> records = [];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      records.add(storage.getDailyRecord(date));
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyRecord?>>(
      future: _monthlyDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data!;
        // Sort newest first for the list
        final reversedRecords = records.reversed.toList();
        
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
    int totalSalahPossible = records.length * 5;
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Text("$percentage%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const Text("Monthly Salah Consistency", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Fajr", totalFajr),
              _buildStatItem("Dhuhr", totalDhuhr),
              _buildStatItem("Asr", totalAsr),
              _buildStatItem("Maghrib", totalMaghrib),
              _buildStatItem("Isha", totalIsha),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHistoryList(List<DailyRecord?> reversedRecords) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reversedRecords.length,
      itemBuilder: (context, index) {
        final record = reversedRecords[index];
        if (record == null) return const SizedBox.shrink();
        
        int completed = 0;
        if (record.salah['Fajr'] == true) completed++;
        if (record.salah['Dhuhr'] == true) completed++;
        if (record.salah['Asr'] == true) completed++;
        if (record.salah['Maghrib'] == true) completed++;
        if (record.salah['Isha'] == true) completed++;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('EEEE, d MMMM').format(record.date), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: completed == 5 ? AppColors.accent.withOpacity(0.2) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Text("$completed/5", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: completed == 5 ? AppColors.primary : Colors.grey)),
                  ),
                ],
              ),
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(record.notes!, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
              ]
            ],
          ),
        );
      },
    );
  }
}

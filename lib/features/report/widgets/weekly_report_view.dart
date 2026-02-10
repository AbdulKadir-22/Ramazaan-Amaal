import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../home/models/daily_record.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/constants/app_colors.dart';

class WeeklyReportView extends StatefulWidget {
  const WeeklyReportView({super.key});

  @override
  State<WeeklyReportView> createState() => _WeeklyReportViewState();
}

class _WeeklyReportViewState extends State<WeeklyReportView> {
  late Future<List<DailyRecord?>> _weeklyDataFuture;

  @override
  void initState() {
    super.initState();
    _weeklyDataFuture = _fetchWeeklyData();
  }

  Future<List<DailyRecord?>> _fetchWeeklyData() async {
    final storage = StorageService();
    final now = DateTime.now();
    List<DailyRecord?> records = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      records.add(storage.getDailyRecord(date));
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyRecord?>>(
      future: _weeklyDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data!;
        
        return Column(
          children: [
            _buildWeeklySummary(records), // New Summary Section
            const SizedBox(height: 24),
            _buildWeeklyChart(records),
            const SizedBox(height: 24),
            _buildNotesList(records),
          ],
        );
      },
    );
  }

  Widget _buildWeeklySummary(List<DailyRecord?> records) {
    int totalPages = 0;
    int totalNawafil = 0;
    int prayersOffered = 0;
    int totalPrayers = records.length * 5;

    for (var record in records) {
      if (record != null) {
        totalPages += record.tilawatPages;
        
        // Count Nawafil
        if (record.extraSalah['Tahajjud'] == true) totalNawafil++;
        if (record.extraSalah['Ishraq'] == true) totalNawafil++;
        if (record.extraSalah['Chasht'] == true) totalNawafil++;
        if (record.extraSalah['Awwabin'] == true) totalNawafil++;

        // Count Fard
        if (record.salah['Fajr'] == true) prayersOffered++;
        if (record.salah['Dhuhr'] == true) prayersOffered++;
        if (record.salah['Asr'] == true) prayersOffered++;
        if (record.salah['Maghrib'] == true) prayersOffered++;
        if (record.salah['Isha'] == true) prayersOffered++;
      }
    }

    return Row(
      children: [
        Expanded(child: _buildSummaryCard("Total Tilawat", "$totalPages Pages", Icons.menu_book_rounded, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryCard("Avg Consistency", "${((prayersOffered / totalPrayers) * 100).toInt()}%", Icons.trending_up, Colors.green)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<DailyRecord?> records) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Salah Consistency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: records.asMap().entries.map((entry) {
              final record = entry.value;
              final index = entry.key;
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              
              int completed = 0;
              if (record != null) {
                if (record.salah['Fajr'] == true) completed++;
                if (record.salah['Dhuhr'] == true) completed++;
                if (record.salah['Asr'] == true) completed++;
                if (record.salah['Maghrib'] == true) completed++;
                if (record.salah['Isha'] == true) completed++;
              }
              
              double heightFactor = completed / 5.0;
              
              return Column(
                children: [
                   Container(
                     width: 12,
                     height: 100 * (heightFactor == 0 ? 0.05 : heightFactor), // Min height to show bar
                     decoration: BoxDecoration(
                       color: heightFactor == 0 ? Colors.grey.shade200 : AppColors.primary.withOpacity(0.6 + (heightFactor * 0.4)),
                       borderRadius: BorderRadius.circular(6),
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(DateFormat('E').format(date)[0], style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<DailyRecord?> records) {
    // Filter records with notes
    final notes = records.where((r) => r != null && r.notes != null && r.notes!.isNotEmpty).toList().reversed.toList();
    
    if (notes.isEmpty) {
      return const SizedBox.shrink(); // No notes to show
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text("Weekly Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ),
        ...notes.map((record) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('EEEE, d MMM').format(record!.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(record.notes!, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4)),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

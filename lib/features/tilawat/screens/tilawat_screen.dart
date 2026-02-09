import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tilawat_provider.dart';
import '../widgets/tilawat_stats_card.dart';
import '../widgets/tilawat_input_section.dart';
import '../widgets/recent_entries_list.dart';

class TilawatScreen extends StatefulWidget {
  const TilawatScreen({super.key});

  @override
  State<TilawatScreen> createState() => _TilawatScreenState();
}

class _TilawatScreenState extends State<TilawatScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    Future.microtask(() => 
      Provider.of<TilawatProvider>(context, listen: false).loadTilawatData()
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current Date Formatting
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM').format(now);
    
    // You might want to calculate Ramadan Day dynamically here
    // For now, hardcoded as per UI
    final ramadanDay = "Ramadan Day 1"; 

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6),
      body: SafeArea(
        child: Consumer<TilawatProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header
                  _buildHeader(context, dateStr, ramadanDay),

                  const SizedBox(height: 30),

                  // 2. Main Stats Card
                  TilawatStatsCard(
                    currentJuz: provider.currentJuz,
                    totalPages: provider.totalPagesRead,
                    progress: provider.progressPercentage,
                  ),

                  const SizedBox(height: 32),

                  // 3. Add Input Section
                  const TilawatInputSection(),

                  const SizedBox(height: 32),

                  // 4. Recent Entries Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Entries",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F1D),
                        ),
                      ),
                      TextButton(
                        onPressed: () {}, 
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. Recent Entries List
                  if (provider.tilawatLogs.isEmpty)
                    _buildEmptyState()
                  else
                    ...provider.tilawatLogs.take(3).map((log) {
                      final logDate = DateTime.parse(log['date']);
                      final isToday = logDate.year == now.year && 
                                    logDate.month == now.month && 
                                    logDate.day == now.day;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RecentEntryItem(
                          date: logDate,
                          juz: log['juz'],
                          pages: log['pages'],
                          isHighlight: isToday,
                        ),
                      );
                    }),

                  const SizedBox(height: 40),

                  // 6. Footer Reminder
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showTimePicker(context, provider),
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Color(0xFF7986CB)),
                      label: const Text(
                        "Set Tilawat Reminder",
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, TilawatProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      provider.setTilawatReminder(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder set for ${picked.format(context)}")),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        "No recitation logged yet.\nStart your journey today!",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String dateStr, String ramadanDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          color: Colors.black87,
        ),
        const SizedBox(height: 20),
        const Text(
          "Tilawat",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1F1D),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Qur'an progress for today",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$ramadanDay • $dateStr",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}
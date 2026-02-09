import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/zikr_provider.dart';
import '../widgets/custom_time_picker.dart'; // Import the new picker

class ZikrDetailScreen extends StatefulWidget {
  final Map<String, dynamic> zikrData;

  const ZikrDetailScreen({super.key, required this.zikrData});

  @override
  State<ZikrDetailScreen> createState() => _ZikrDetailScreenState();
}

class _ZikrDetailScreenState extends State<ZikrDetailScreen> {
  late int _currentCount;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.zikrData['currentCount'];
  }

  void _increment() {
    setState(() => _currentCount++);
    // Update Provider
    context.read<ZikrProvider>().updateCount(widget.zikrData['id'], _currentCount);
  }

  void _showTimePicker(BuildContext context, String currentReminder) {
    // Parse currentReminder string "HH:MM" to TimeOfDay if exists, else use now
    TimeOfDay initial = TimeOfDay.now();
    if (currentReminder.isNotEmpty && currentReminder.contains(":")) {
      final parts = currentReminder.split(":");
      initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomTimePickerSheet(
        initialTime: initial,
        onTimeSelected: (picked) {
          context.read<ZikrProvider>().updateReminder(widget.zikrData['id'], picked);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch specific item updates
    final zikr = context.select<ZikrProvider, Map<String, dynamic>>(
      (p) => p.zikrList.firstWhere((e) => e['id'] == widget.zikrData['id'], orElse: () => widget.zikrData),
    );

    // If item was deleted, just return empty container (navigating back handled by delete action usually)
    if (zikr.isEmpty) return const SizedBox();

    final int total = zikr['targetCount'];
    final double progress = (total == 0) ? 0 : (_currentCount / total).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          zikr['name'],
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Main Counter Card (UI from single_tasbeeh.dart)
              GestureDetector(
                onTap: _increment, // Tap anywhere on card to count
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Big Count Text
                      Text(
                        "$_currentCount",
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        "/ $total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Progress Bar
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF1F3F4),
                        color: AppColors.primary,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Tap to count",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Settings Section
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 12),
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
              
              // Reminder Row
              _buildSettingItem(
                label: "Daily Reminder",
                value: zikr['reminderTime'] ?? "Not Set",
                icon: Icons.notifications_outlined,
                onTap: () => _showTimePicker(context, zikr['reminderTime'] ?? ""),
              ),
              
              const SizedBox(height: 12),
              
              // Target Row
              _buildSettingItem(
                label: "Daily Target",
                value: "$total",
                icon: Icons.flag_outlined,
                onTap: () {
                  // Optional: Add logic to edit target here similar to _showAddDialog
                },
              ),

              const SizedBox(height: 40),

              // 3. Delete Button (UI from single_tasbeeh.dart - TextButton style)
              TextButton(
                onPressed: () {
                  context.read<ZikrProvider>().deleteZikr(zikr['id']);
                  Navigator.pop(context);
                },
                child: Text(
                  "Delete Zikr",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textDark, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
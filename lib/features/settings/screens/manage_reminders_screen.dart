import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/notification_settings_provider.dart';

class ManageRemindersScreen extends StatelessWidget {
  const ManageRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<NotificationSettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Reminders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildReminderCard(
              title: "Daily Report",
              subtitle: "Remind me at 10 PM to check my progress",
              value: settings.dailyReportEnabled,
              onChanged: (v) => settings.setDailyReportEnabled(v),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              title: "Prayer Times",
              subtitle: "Get notified for each Salah time",
              value: settings.salahEnabled,
              onChanged: (v) => settings.setSalahEnabled(v),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              title: "Tilawat Reminder",
              subtitle: "Encouragement to read Qur'an",
              value: settings.tilawatEnabled,
              onChanged: (v) => settings.setTilawatEnabled(v),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              title: "Zikr Reminder",
              subtitle: "Master switch for all Zikr reminders",
              value: settings.zikrEnabled,
              onChanged: (v) => settings.setZikrEnabled(v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        activeColor: const Color(0xFF10B981),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
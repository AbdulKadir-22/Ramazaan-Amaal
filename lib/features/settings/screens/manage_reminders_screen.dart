import 'package:flutter/material.dart';

class ManageRemindersScreen extends StatefulWidget {
  const ManageRemindersScreen({super.key});

  @override
  State<ManageRemindersScreen> createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  // Example state variables
  bool _salahNotifications = true;
  bool _morningAdhkar = true;
  bool _eveningAdhkar = true;
  bool _fridayReminder = false;

  @override
  Widget build(BuildContext context) {
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
              title: "Prayer Times",
              subtitle: "Get notified for each Salah time",
              value: _salahNotifications,
              onChanged: (v) => setState(() => _salahNotifications = v),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              title: "Morning Adhkar",
              subtitle: "Reminder after Fajr",
              value: _morningAdhkar,
              onChanged: (v) => setState(() => _morningAdhkar = v),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              title: "Evening Adhkar",
              subtitle: "Reminder after Asr",
              value: _eveningAdhkar,
              onChanged: (v) => setState(() => _eveningAdhkar = v),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              title: "Surah Al-Kahf",
              subtitle: "Weekly reminder on Fridays",
              value: _fridayReminder,
              onChanged: (v) => setState(() => _fridayReminder = v),
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
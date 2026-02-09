import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("GENERAL"),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: "Language",
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: const [Text("English", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 14)), SizedBox(width: 8), Icon(Icons.chevron_right, color: Colors.grey, size: 20)]),
                      showDivider: true,
                    ),
                    _buildSettingsTile(icon: Icons.notifications_active_outlined, title: "Manage Reminders", showDivider: false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("ABOUT US"),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(icon: Icons.people_outline, title: "About the Developers", showDivider: true),
                    _buildSettingsTile(icon: Icons.explore_outlined, title: "Our Journey", showDivider: false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(decoration: _cardDecoration(), child: _buildSettingsTile(icon: Icons.history_edu_rounded, title: "Add Past Entry", showDivider: false)),
              const SizedBox(height: 16),
              Container(decoration: _cardDecoration(), child: _buildSettingsTile(icon: Icons.notification_add_outlined, title: "Send Notification", showDivider: false)),
              const SizedBox(height: 40),
              Center(
                child: Column(children: const [
                  Text("Designed and developed for the Ummah", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text("جزاك الله خيرا", style: TextStyle(color: Color(0xFF1A1F1D), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text("v1.2.4 (Build 482)", style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 10)),
                ]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12.0, left: 4), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.0)));
  }

  Widget _buildSettingsTile({required IconData icon, required String title, Widget? trailing, bool showDivider = true}) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF10B981), size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1F1D)))),
          if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ]),
      ),
      if (showDivider) const Divider(height: 1, thickness: 1, indent: 72, color: Color(0xFFF5F5F5)),
    ]);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))]);
  }
}
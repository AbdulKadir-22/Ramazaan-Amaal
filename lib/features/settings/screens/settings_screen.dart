import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this to pubspec.yaml if you want clickable links
import 'manage_reminders_screen.dart';
import 'add_past_entry_screen.dart';
import '../widgets/admin_notification_sheet.dart';
import '../../../core/services/notification_service.dart';

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
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: const [
                        Text("English", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 14)),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey, size: 20)
                      ]),
                      showDivider: true,
                      onTap: () {}, // Language logic here later
                    ),
                    _buildSettingsTile(
                      icon: Icons.notifications_active_outlined,
                      title: "Manage Reminders",
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageRemindersScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("ABOUT US"),
              Container(
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.people_outline,
                      title: "About the Developers",
                      showDivider: true,
                      onTap: () => _showDeveloperModal(context),
                    ),
                    _buildSettingsTile(
                      icon: Icons.explore_outlined,
                      title: "Our Journey",
                      showDivider: false,
                      onTap: () => _showJourneyModal(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: _cardDecoration(),
                child: _buildSettingsTile(
                  icon: Icons.history_edu_rounded,
                  title: "Add Past Entry",
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPastEntryScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: _cardDecoration(),
                child: _buildSettingsTile(
                  icon: Icons.notification_add_outlined,
                  title: "Send Notification",
                  showDivider: false,
                  onTap: () {
                    // Calling the function from our new widget file
                    showAdminNotificationModal(context);
                  }, 
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(children: const [
                  Text("Designed and developed for the Ummah", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text("جزاك الله خيرا", style: TextStyle(color: Color(0xFF1A1F1D), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text("v1.0.0 (Build 482)", style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 10)),
                ]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeveloperModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.person, color: Color(0xFF10B981), size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Abdulkadir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Lead Developer", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Assalamu Alaikum! I'm a Flutter developer passionate about building tools that benefit the Ummah. Tarteeb is a passion project designed to help us organize our spiritual obligations.",
              style: TextStyle(color: Color(0xFF1A1F1D), height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFAF6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8F5E9)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.code, color: Color(0xFF10B981)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text("Sponsor on GitHub", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text("@Abdulkadir", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), 
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12.0, left: 4), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.0)));
  }

  Widget _buildSettingsTile({required IconData icon, required String title, Widget? trailing, bool showDivider = true, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [
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
      ]),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.015),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _showJourneyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text(
                "Our Journey",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1F1D)),
              ),
              const SizedBox(height: 16),
              const Text(
                "Assalamu Alaikum! Welcome to Tarteeb.\n\n"
                "This project started with a simple vision: to create a digital companion that helps the Ummah stay consistent with their daily Amaal, especially during the blessed month of Ramadan.\n\n"
                "Our journey has been one of learning and dedication. Every feature, from the Tasbeeh counter to the daily progress reports, has been designed with the goal of making spiritual growth easier and more accessible for everyone.\n\n"
                "We are constantly evolving and plan to add more features that will support your journey towards a better version of yourself. Thank you for being a part of our story.\n\n"
                "May Allah (SWT) accept our efforts and keep us steadfast. Ameen.",
                style: TextStyle(color: Color(0xFF1A1F1D), height: 1.6, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "More updates coming soon, In Sha Allah!",
                        style: TextStyle(
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
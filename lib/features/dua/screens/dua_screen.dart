import 'package:flutter/material.dart';
// Adjust import path if needed
import '../../../core/constants/app_colors.dart'; 

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6), // Warm off-white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hide back button for main tab
        title: const Text(
          "Dua List",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, size: 24, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Essentials",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildDuaCard(
                context,
                title: "Dua for Suhoor",
                subtitle: "Recited before dawn",
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFF00BCD4),
                bgColor: const Color(0xFFE0F7FA),
                onTap: () => _showDuaModal(context, "Dua for Suhoor", 
                  "Wa bisawmi ghadinn nawaiytu min shahri ramadan.", 
                  "I intend to keep the fast for tomorrow in the month of Ramadan."),
              ),
              const SizedBox(height: 16),
              _buildDuaCard(
                context,
                title: "Dua for Iftaar",
                subtitle: "Recited at sunset",
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () => _showDuaModal(context, "Dua for Iftaar", 
                  "Allahumma inni laka sumtu wa bika aamantu wa 'alayka tawakkaltu wa 'ala rizq-ika aftartu.", 
                  "O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance."),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuaCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1F1D))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  void _showDuaModal(BuildContext context, String title, String arabic, String translation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
            const SizedBox(height: 24),
            Text(arabic, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.6, color: Color(0xFF1A1F1D))),
            const SizedBox(height: 24),
            Text(translation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
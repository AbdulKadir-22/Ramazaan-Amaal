import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart'; 
import '../../home/providers/daily_progress_provider.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyProgressProvider>();

    final List<Map<String, dynamic>> duas = [
      {
        'title': "Dua of Suhoor",
        'subtitle': "Recited before dawn",
        'icon': Icons.wb_sunny_outlined,
        'iconColor': const Color(0xFF00BCD4),
        'bgColor': const Color(0xFFE0F7FA),
        'arabic': "Wa bisawmi ghadinn nawaiytu min shahri ramadan.",
        'translation': "I intend to keep the fast for tomorrow in the month of Ramadan.",
      },
      {
        'title': "Dua of Iftaar",
        'subtitle': "Recited at sunset",
        'icon': Icons.nightlight_round,
        'iconColor': const Color(0xFF10B981),
        'bgColor': const Color(0xFFE8F5E9),
        'arabic': "Allahumma inni laka sumtu wa bika aamantu wa 'alayka tawakkaltu wa 'ala rizq-ika aftartu.",
        'translation': "O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance.",
      },
      {
        'title': "1st Ashra Dua",
        'subtitle': "Dua of Mercy (Days 1-10)",
        'icon': Icons.favorite_border,
        'iconColor': Colors.pink,
        'bgColor': const Color(0xFFFCE4EC),
        'arabic': "Rabbighfir warham wa anta khairur raahimeen.",
        'translation': "O my Lord! Forgive and have mercy, for You are the best of those who show mercy.",
      },
      {
        'title': "2nd Ashra Dua",
        'subtitle': "Dua of Forgiveness (Days 11-20)",
        'icon': Icons.clean_hands,
        'iconColor': Colors.amber,
        'bgColor': const Color(0xFFFFF8E1),
        'arabic': "Astaghfirullaha Rabbi min kulli zanbiw wa atoobu ilaih.",
        'translation': "I seek forgiveness from Allah, my Lord, from every sin I committed.",
      },
      {
        'title': "3rd Ashra Dua",
        'subtitle': "Dua of Safety from Hell (Days 21-30)",
        'icon': Icons.shield_outlined,
        'iconColor': Colors.deepOrange,
        'bgColor': const Color(0xFFFBE9E7),
        'arabic': "Allahumma Ajirni minan Naar.",
        'translation': "O Allah! Save me from the fire of Hell.",
      },
      {
        'title': "Laylatul Qadr Dua",
        'subtitle': "Recited in the last 10 nights",
        'icon': Icons.star_outline,
        'iconColor': Colors.indigo,
        'bgColor': const Color(0xFFE8EAF6),
        'arabic': "Allahumma innaka 'afuwwun tuhibbul 'afwa fa'fu 'anni.",
        'translation': "O Allah! You are most Forgiving, and You love forgiveness; so forgive me.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Dua List",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: duas.length,
          itemBuilder: (context, index) {
            final duo = duas[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildDuaCard(
                context,
                title: duo['title'],
                subtitle: duo['subtitle'],
                icon: duo['icon'],
                iconColor: duo['iconColor'],
                bgColor: duo['bgColor'],
                isChecked: provider.isDuaDone(duo['title']),
                onToggle: () => provider.toggleDua(duo['title']),
                onTap: () => _showDuaModal(context, duo['title'], duo['arabic'], duo['translation']),
              ),
            );
          },
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
    required bool isChecked,
    required VoidCallback onToggle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isChecked ? AppColors.primary : Colors.transparent,
                  border: isChecked ? null : Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDuaModal(BuildContext context, String title, String arabic, String translation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
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
            Text(arabic, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.6, color: Color(0xFF1A1F1D))),
            const SizedBox(height: 24),
            Text(translation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

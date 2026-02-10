import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Import Core & Providers ---
import '../../../core/constants/app_colors.dart';
import '../providers/daily_progress_provider.dart';
import '../../salah/screens/salah_detail_screen.dart';
import '../../zikr/providers/zikr_provider.dart';
import '../../zikr/screens/tasbeeh_list_screen.dart';
import '../../zikr/screens/zikr_detail_screen.dart';
import '../../tilawat/providers/tilawat_provider.dart';
import '../../tilawat/screens/tilawat_screen.dart';

// --- Import Feature Screens for Navigation ---
// Make sure these files exist as created in the previous step
import '../../dua/screens/dua_screen.dart';
import '../../report/screens/report_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // The 4 Main Screens for the BottomNavigationBar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeContent(),   // 0: Dashboard (Your original home logic)
      const DuaScreen(),      // 1: Dua
      const ReportScreen(),   // 2: Report
      const SettingsScreen(), // 3: Settings
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // IndexedStack preserves the state of each page (so you don't lose scroll position or input)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled), 
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism), // Icon for Dua
            label: 'Dua'
          ), 
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded), 
            label: 'Report'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), 
            label: 'Settings'
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// INTERNAL WIDGET: _HomeContent
// This contains the Dashboard logic (Suhoor, Salah, Tilawat, Zikr cards)
// ==============================================================================
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    // Watch providers for real-time updates
    final progressProvider = context.watch<DailyProgressProvider>();
    final zikrProvider = context.watch<ZikrProvider>();
    final tilawatProvider = context.watch<TilawatProvider>();
    final zikrList = zikrProvider.zikrList;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            
            // 1. Suhoor Card
            _buildSuhoorCard(context, progressProvider),
            const SizedBox(height: 16),
            
            // 2. Salah Card
            _buildSalahCard(context),
            const SizedBox(height: 16),
            
            // 3. Extra Namaz Card
            _buildExtraNamazCard(context, progressProvider),
            const SizedBox(height: 16),
            
            // 4. Tilawat Card
            _buildTilawatCard(context, tilawatProvider),
            const SizedBox(height: 16),
            
            // 5. Daily Reflection Card
            _buildReflectionCard(context, progressProvider),
            const SizedBox(height: 16),

            // 6. Zikr Card
            _buildZikrCard(context, zikrList),
            
            // Bottom spacing to ensure content isn't hidden by navbar
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Ramazan Amaal\nTracker",
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w800, 
            height: 1.2, 
            color: AppColors.textDark
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text("12 March | 1", style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
            Text("Ramazan", style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildSuhoorCard(BuildContext context, DailyProgressProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Suhoor Niyat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          GestureDetector(
            onTap: () => context.read<DailyProgressProvider>().toggleSuhoor(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: provider.isSuhoorDone ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: provider.isSuhoorDone ? null : Border.all(color: Colors.grey.shade300, width: 2)
              ),
              child: provider.isSuhoorDone ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalahCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 10, bottom: 5), child: Text("Salah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          _buildSalahItem(context, "Fajr"), _buildDivider(),
          _buildSalahItem(context, "Dhuhr"), _buildDivider(),
          _buildSalahItem(context, "Asr"), _buildDivider(),
          _buildSalahItem(context, "Maghrib"), _buildDivider(),
          _buildSalahItem(context, "Isha"), _buildDivider(),
          _buildSalahItem(context, "Taraweeh"),
        ],
      ),
    );
  }

  Widget _buildSalahItem(BuildContext context, String name) {
    final isCompleted = context.watch<DailyProgressProvider>().isSalahCompleted(name);
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SalahDetailScreen(prayerName: name))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Row(children: [
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF424242))), 
              if (isCompleted) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: AppColors.primary, size: 16)]
            ]), 
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20)
          ]
        ),
      ),
    );
  }

  Widget _buildExtraNamazCard(BuildContext context, DailyProgressProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Extra Namaz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)), TextButton(onPressed: () {}, child: const Text("Add more", style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w500)))]),
        const SizedBox(height: 16),
        _buildExtraSalahItem(context, "Tahajjud", provider.isExtraSalahDone("Tahajjud")), const SizedBox(height: 14),
        _buildExtraSalahItem(context, "Ishraq", provider.isExtraSalahDone("Ishraq")), const SizedBox(height: 14),
        _buildExtraSalahItem(context, "Chasht", provider.isExtraSalahDone("Chasht")), const SizedBox(height: 14),
        _buildExtraSalahItem(context, "Awwabin", provider.isExtraSalahDone("Awwabin")),
      ]),
    );
  }

  Widget _buildExtraSalahItem(BuildContext context, String name, bool isChecked) {
    // Checkbox state typically comes from parent, but let's ensure we are reactive if needed
    // In this specific build flow, `_buildExtraNamazCard` passes `provider.isExtraSalahDone`
    // and `_buildExtraNamazCard` is called in `build` where `provider` is obtained via `watch`.
    // So `isChecked` passed down SHOULD be correct if the parent rebuilds.
    // Let's check `_buildSuhoorCard` too.
    return Row(children: [
      GestureDetector(
        onTap: () => context.read<DailyProgressProvider>().toggleExtraSalah(name),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 24, height: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: isChecked ? AppColors.primary : Colors.grey.shade300, width: 2), color: isChecked ? AppColors.primary : Colors.transparent), child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
      ),
      const SizedBox(width: 12),
      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF424242))),
    ]);
  }

  Widget _buildTilawatCard(BuildContext context, TilawatProvider tilawatProvider) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TilawatScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tilawat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text("Progress ${(tilawatProvider.progressPercentage * 100).toInt()}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Juz ${tilawatProvider.currentJuz} • ${tilawatProvider.totalPagesRead} Pages Read", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: tilawatProvider.progressPercentage,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildReflectionCard(BuildContext context, DailyProgressProvider provider) {
    final reflections = [
      "Avoided Lying",
      "Avoided Backbiting",
      "Lowered Gaze",
      "Avoided Argument",
      "Controlled Negative Thoughts"
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daily Reflection", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text("Self Control & Habits", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          ...reflections.map((r) => _buildReflectionItem(context, r, provider.isReflectionDone(r))).toList(),
        ],
      ),
    );
  }

  Widget _buildReflectionItem(BuildContext context, String name, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.read<DailyProgressProvider>().toggleReflection(name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), 
            width: 24, height: 24, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6), 
              border: Border.all(color: isChecked ? AppColors.primary : Colors.grey.shade300, width: 2), 
              color: isChecked ? AppColors.primary : Colors.transparent
            ), 
            child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null
          ),
        ),
        const SizedBox(width: 12),
        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF424242))),
      ]),
    );
  }

  Widget _buildZikrCard(BuildContext context, List<Map<String, dynamic>> zikrList) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbeehListScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Zikr", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)), Text("Total / Expected", style: TextStyle(color: Colors.grey, fontSize: 12))]),
          const SizedBox(height: 16),
          if (zikrList.isEmpty) Center(child: TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbeehListScreen())), icon: const Icon(Icons.add, color: AppColors.primary), label: const Text("Start your first Zikr", style: TextStyle(color: AppColors.primary))))
          else ListView.separated(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: zikrList.length > 3 ? 3 : zikrList.length, separatorBuilder: (context, index) => const SizedBox(height: 12), itemBuilder: (context, index) => _buildDynamicZikrItem(context, zikrList[index])),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("// Tap card to manage all", style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: Color(0xFFB0B0B0))), if (zikrList.isNotEmpty) const Icon(Icons.arrow_forward, size: 14, color: Colors.grey)]),
        ]),
      ),
    );
  }

  Widget _buildDynamicZikrItem(BuildContext context, Map<String, dynamic> item) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(item['name'] ?? 'Zikr', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF424242)), overflow: TextOverflow.ellipsis)), SizedBox(height: 30, child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ZikrDetailScreen(zikrData: item))), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE0E0E0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text("Enter", style: TextStyle(color: Color(0xFF616161), fontSize: 12, fontWeight: FontWeight.w600))))]);
  }

  Widget _buildDivider() => const Divider(height: 1, color: Color(0xFFEEEEEE));

  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]);
}
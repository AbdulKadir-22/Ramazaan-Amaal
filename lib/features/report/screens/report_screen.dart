import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

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
          "Report",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share, size: 22, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              _buildTabSwitcher(),
              const SizedBox(height: 30),
              _buildCircularProgress(),
              const SizedBox(height: 16),
              const Text("Today: 72% Complete", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _buildInfoCard(title: "Roza", icon: Icons.wb_twilight_rounded, content: _buildRozaContent())),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard(title: "Tilawat", icon: Icons.menu_book_rounded, content: _buildTilawatContent())),
                ],
              ),
              const SizedBox(height: 16),
              _buildNamazCard(),
              const SizedBox(height: 16),
              _buildZikrDuasCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        _buildTabItem("Daily", isSelected: true),
        _buildTabItem("Weekly", isSelected: false),
        _buildTabItem("Ramadan", isSelected: false),
      ]),
    );
  }

  Widget _buildTabItem(String title, {required bool isSelected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
        ),
        child: Center(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isSelected ? const Color(0xFF10B981) : Colors.grey))),
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(width: 160, height: 160, child: CircularProgressIndicator(value: 0.72, strokeWidth: 12, backgroundColor: Colors.grey.shade100, valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)), strokeCap: StrokeCap.round)),
      Column(mainAxisSize: MainAxisSize.min, children: const [Text("72%", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF1A1F1D)))]),
    ]);
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)), Icon(icon, size: 18, color: const Color(0xFF10B981))]),
        content,
      ]),
    );
  }

  Widget _buildRozaContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Kept", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1F1D))),
      const SizedBox(height: 4),
      Row(children: const [Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)), SizedBox(width: 4), Text("Alhamdulillah", style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600))])
    ]);
  }

  Widget _buildTilawatContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: const TextSpan(style: TextStyle(color: Color(0xFF1A1F1D)), children: [TextSpan(text: "12 ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), TextSpan(text: "pages", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))])),
      const SizedBox(height: 6),
      const Text("Juz 3 • Surah Al-Imran", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey))
    ]);
  }

  Widget _buildNamazCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Namaz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Text("4/5 Completed", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)))]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildNamazStatus("Fajr", true), _buildNamazStatus("Dhuhr", true), _buildNamazStatus("Asr", true), _buildNamazStatus("Maghrib", true), _buildNamazStatus("Isha", false)
        ])
      ]),
    );
  }

  Widget _buildNamazStatus(String name, bool isDone) {
    return Column(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5), border: isDone ? null : Border.all(color: Colors.grey.shade300)), child: isDone ? const Icon(Icons.check, size: 20, color: Color(0xFF10B981)) : const Icon(Icons.remove, size: 20, color: Colors.grey)),
      const SizedBox(height: 8),
      Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500))
    ]);
  }

  Widget _buildZikrDuasCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Zikr & Duas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Icon(Icons.pie_chart_outline, size: 18, color: Colors.grey)]),
        const SizedBox(height: 20),
        _buildZikrProgress("Astaghfirullah", "Forgiveness", 100, 100),
        const SizedBox(height: 16),
        _buildZikrProgress("Alhamdulillah", "Gratitude", 33, 100),
      ]),
    );
  }

  Widget _buildZikrProgress(String title, String subtitle, int current, int total) {
    bool isComplete = current >= total;
    return Row(children: [
      Container(width: 4, height: 36, decoration: BoxDecoration(color: isComplete ? const Color(0xFF10B981) : Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1F1D), fontSize: 14)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11))])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isComplete ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)), child: Text("$current/$total", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isComplete ? const Color(0xFF10B981) : Colors.grey))),
    ]);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]);
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/providers/daily_progress_provider.dart';
import '../providers/dua_provider.dart';
import '../models/dua_model.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duaProvider = context.watch<DuaProvider>();
    final dailyProvider = context.watch<DailyProgressProvider>();
    final filteredDuas = duaProvider.duas;
    final allDuas = duaProvider.allDuas;

    // Calculate progress based on all duas (not just filtered ones)
    final totalDuas = allDuas.length;
    final readCount = allDuas.where((d) => dailyProvider.isDuaDone(d.title)).length;
    final progress = totalDuas > 0 ? readCount / totalDuas : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      body: Column(
        children: [
          _buildHeader(context, readCount, progress),
          Expanded(
            child: duaProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildSearchBar(duaProvider),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                          itemCount: filteredDuas.length,
                          itemBuilder: (context, index) {
                            final dua = filteredDuas[index];
                            final isDone = dailyProvider.isDuaDone(dua.title);
                            return _buildDuaCard(
                              context,
                              dua: dua,
                              isDone: isDone,
                              onToggle: () => dailyProvider.toggleDua(dua.title),
                              onTap: () => _showDuaModal(context, dua),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int readCount, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Daily Duas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$readCount Duas Completed Today",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(DuaProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: provider.searchDuas,
          decoration: const InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
            prefixIcon: Icon(Icons.circle, color: Color(0xFF346943), size: 12), // Placeholder for the dot in design
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            border: InputBorder.none,
            prefixIconConstraints: BoxConstraints(minWidth: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildDuaCard(
    BuildContext context, {
    required DuaModel dua,
    required bool isDone,
    required VoidCallback onToggle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? AppColors.primary.withOpacity(0.08) : Colors.white, // Light green tint if done
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDone ? AppColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDone ? Colors.white : dua.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(dua.iconData, color: dua.iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dua.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F1D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dua.category,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.primary : Colors.white,
                  border: isDone ? null : Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDuaModal(BuildContext context, DuaModel dua) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              dua.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF346943),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    dua.arabic,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.8,
                      color: Color(0xFF1A1F1D),
                      fontFamily: 'Arabic', // Assuming you might have a font, otherwise fallback
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Transliteration",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              dua.transliteration,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF4A4A4A), height: 1.4),
            ),
            const SizedBox(height: 24),
            const Text(
              "Translation",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              dua.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF4A4A4A), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

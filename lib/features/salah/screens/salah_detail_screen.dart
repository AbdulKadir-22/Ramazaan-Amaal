import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/prayer_data.dart';
import '../../home/providers/daily_progress_provider.dart';

class SalahDetailScreen extends StatefulWidget {
  final String prayerName;

  const SalahDetailScreen({super.key, required this.prayerName});

  @override
  State<SalahDetailScreen> createState() => _SalahDetailScreenState();
}

class _SalahDetailScreenState extends State<SalahDetailScreen> {
  // Local state for checking off individual rakats (optional, not stored persistently for simplicity)
  final Set<int> _checkedItems = {}; 

  @override
  Widget build(BuildContext context) {
    // Get data structure for this specific prayer
    final List<PrayerUnit> units = PrayerData.prayerStructure[widget.prayerName] ?? [];
    
    // Watch provider for overall completion status
    final provider = context.watch<DailyProgressProvider>();
    final bool isCompletedToday = provider.isSalahCompleted(widget.prayerName);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textDark,
                  ),
                  Text(
                    widget.prayerName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  // "Set time" button (Placeholder functionality)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD1C4E9)),
                    ),
                    child: const Text(
                      "Set time",
                      style: TextStyle(
                        color: Color(0xFF7E57C2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. List of Rakats
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: units.length,
                itemBuilder: (context, index) {
                  final unit = units[index];
                  return _buildPrayerItem(index, unit);
                },
              ),
            ),

            // 3. Footer Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    "\"Prayer is the pillar of religion.\"",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark as complete in Provider and go back
                        context.read<DailyProgressProvider>().setSalahCompleted(widget.prayerName, true);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompletedToday ? Colors.grey : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        isCompletedToday ? "Completed" : "Complete for Today",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerItem(int index, PrayerUnit unit) {
    bool isChecked = _checkedItems.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            decoration: BoxDecoration(
              color: unit.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(unit.icon, color: unit.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                if (unit.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    unit.subtitle!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w400),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => isChecked ? _checkedItems.remove(index) : _checkedItems.add(index)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? AppColors.primary : Colors.transparent,
                border: isChecked ? null : Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: isChecked ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
            ),
          ),
        ],
      ),
    );
  }
}
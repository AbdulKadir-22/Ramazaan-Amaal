import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentEntryItem extends StatelessWidget {
  final DateTime date;
  final int juz;
  final int pages;
  final bool isHighlight;

  const RecentEntryItem({
    super.key,
    required this.date,
    required this.juz,
    required this.pages,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    // Format date: e.g., "12 Mar" or "Today"
    final dateStr = DateFormat('MMM d').format(date);
    final displayTitle = isHighlight ? "Today" : dateStr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isHighlight ? const Color(0xFFF0FDF4) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: isHighlight ? const Color(0xFF10B981) : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F1D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Juz $juz • $pages pages",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
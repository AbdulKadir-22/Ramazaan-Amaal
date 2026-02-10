import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/providers/daily_progress_provider.dart'; // Import DailyProgressProvider
import '../providers/tilawat_provider.dart';

class TilawatInputSection extends StatefulWidget {
  const TilawatInputSection({super.key});

  @override
  State<TilawatInputSection> createState() => _TilawatInputSectionState();
}

class _TilawatInputSectionState extends State<TilawatInputSection> {
  int selectedJuz = 1;
  int selectedPages = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Add Today's Tilawat",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F1D),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildJuzDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildPagesDropdown()),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Access Provider via context
              context.read<TilawatProvider>().addLog(selectedJuz, selectedPages);
              
              // Also update DailyProgressProvider for the Report Screen
              context.read<DailyProgressProvider>().updateTilawatPages(selectedPages);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Progress Logged!"),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Log Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJuzDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedJuz,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          isExpanded: true,
          items: List.generate(30, (index) => index + 1).map((juz) {
            return DropdownMenuItem(
              value: juz,
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text("Juz $juz",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242))),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedJuz = val!),
        ),
      ),
    );
  }

  Widget _buildPagesDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedPages,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          isExpanded: true,
          items: [1, 2, 5, 10, 15, 20, 30].map((pages) {
            return DropdownMenuItem(
              value: pages,
              child: Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text("$pages Pages",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF424242))),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedPages = val!),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomTimePickerSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const CustomTimePickerSheet({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePickerSheet> createState() => _CustomTimePickerSheetState();
}

class _CustomTimePickerSheetState extends State<CustomTimePickerSheet> {
  late int selectedHour;
  late int selectedMinute;
  late bool isPm;

  @override
  void initState() {
    super.initState();
    final time = widget.initialTime;
    isPm = time.period == DayPeriod.pm;
    selectedHour = time.hourOfPeriod;
    if (selectedHour == 0) selectedHour = 12; // Handle 12 AM/PM logic
    selectedMinute = time.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Set Reminder Time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Time Picker Row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours
                _buildScrollWheel(
                  itemCount: 12, 
                  initialItem: selectedHour - 1,
                  labelBuilder: (i) => "${i + 1}",
                  onChanged: (val) => setState(() => selectedHour = val + 1),
                ),
                
                const Text(":", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

                // Minutes
                _buildScrollWheel(
                  itemCount: 60, 
                  initialItem: selectedMinute,
                  labelBuilder: (i) => i.toString().padLeft(2, '0'),
                  onChanged: (val) => setState(() => selectedMinute = val),
                ),

                const SizedBox(width: 20),

                // AM/PM Toggle
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAmPmOption("AM", !isPm, () => setState(() => isPm = false)),
                    const SizedBox(height: 12),
                    _buildAmPmOption("PM", isPm, () => setState(() => isPm = true)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Convert back to 24h format for TimeOfDay
                int hour24 = selectedHour;
                if (isPm && selectedHour != 12) hour24 += 12;
                if (!isPm && selectedHour == 12) hour24 = 0;

                widget.onTimeSelected(TimeOfDay(hour: hour24, minute: selectedMinute));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text("Save Reminder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScrollWheel({
    required int itemCount,
    required int initialItem,
    required String Function(int) labelBuilder,
    required Function(int) onChanged,
  }) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: initialItem),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: Text(
                labelBuilder(index),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAmPmOption(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
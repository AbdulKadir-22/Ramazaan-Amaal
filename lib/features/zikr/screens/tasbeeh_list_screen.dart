import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/zikr_provider.dart';
import 'zikr_detail_screen.dart';

class TasbeehListScreen extends StatelessWidget {
  const TasbeehListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zikrProvider = context.watch<ZikrProvider>();
    final zikrList = zikrProvider.zikrList;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textDark,
                  ),
                  const Text(
                    "Tasbeeh",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w800, 
                      color: AppColors.textDark
                    ),
                  ),
                  // Quick Add Button
                  GestureDetector(
                    onTap: () => _showAddDialog(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Quote & List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: zikrList.length + 1, // +1 for the quote header
                itemBuilder: (context, index) {
                  // Show Quote at the top
                  if (index == 0) {
                     return const Padding(
                      padding: EdgeInsets.only(bottom: 24.0, top: 0),
                      child: Text(
                        "\"Remember Allah much so that you may be successful\"\n(Qur'an 62:10)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic, 
                          color: Colors.grey, 
                          fontSize: 13, 
                          height: 1.5
                        ),
                      ),
                    );
                  }
                  
                  final item = zikrList[index - 1];
                  return _buildZikrCard(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZikrCard(BuildContext context, Map<String, dynamic> item) {
    final int current = item['currentCount'];
    final int total = item['targetCount'];
    final bool isCompleted = current >= total;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZikrDetailScreen(zikrData: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Left Side: Text and Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w700, 
                      color: AppColors.textDark
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Count Text or Completed Label
                  if (!isCompleted)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$current",
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: " / $total",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w700, 
                        color: AppColors.primary
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: current / (total == 0 ? 1 : total),
                      backgroundColor: const Color(0xFFF1F3F4),
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Right Side: Circular Counter Button
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Quick Increment
                    context.read<ZikrProvider>().updateCount(item['id'], current + 1);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.primary : const Color(0xFFE8F5E9),
                      border: isCompleted 
                        ? null 
                        : Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        "$current", // Shows current count inside button as per UI
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Only show delete icon if specifically requested by design, 
                // but usually user deletes from detail screen. 
                // Adding a small spacer if needed.
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: "100");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New Zikr", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController, 
              decoration: InputDecoration(
                labelText: "Zikr Name (e.g. SubhanAllah)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController, 
              decoration: InputDecoration(
                labelText: "Target Count",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ), 
              keyboardType: TextInputType.number
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<ZikrProvider>().addZikr(
                  nameController.text, 
                  int.tryParse(targetController.text) ?? 100
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
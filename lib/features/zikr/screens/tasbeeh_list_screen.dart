import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../core/constants/app_colors.dart';
import '../providers/zikr_provider.dart';
import 'zikr_detail_screen.dart';

class TasbeehListScreen extends StatelessWidget {
  const TasbeehListScreen({super.key});

  // Define the specific colors from the design file to ensure exact match
  static const Color _mintGreen = Color(0xFF10B981);
  static const Color _warmOffWhite = Color(0xFFFDFAF6);
  static const Color _darkText = Color(0xFF1A1F1D);

  @override
  Widget build(BuildContext context) {
    final zikrProvider = context.watch<ZikrProvider>();
    final zikrList = zikrProvider.zikrList;

    return Scaffold(
      backgroundColor: _warmOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Back Button, Title, Add Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.black87,
                  ),
                  const Text(
                    "Tasbeeh",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  // Header Add Button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _mintGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 20, color: Colors.white),
                      onPressed: () => _showAddDialog(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Quote
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Text(
                      "\"Remember Allah much so that you may be successful\"\n(Qur'an 62:10)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Zikr List Items
                  if (zikrList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          "No Tasbeeh added yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...zikrList.map((item) => _buildTasbeehCard(context, item)),

                  const SizedBox(height: 10),

                  // Motivational Banner
                  if (zikrList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // Very light green bg
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Keep going!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B5E20),
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Consistency is key to a peaceful heart.",
                                  style: TextStyle(
                                    color: Color(0xFF388E3C),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Abstract shape placeholder
                          Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), _mintGreen],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.waves, color: Colors.white30),
                          )
                        ],
                      ),
                    ),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Bottom Button Section
      bottomSheet: Container(
        color: _warmOffWhite, // Match scaffold bg
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showAddDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mintGreen,
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
                      "Add Tasbeeh / Dhikr",
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
            const SizedBox(height: 12),
            const Text(
              "Daily count resets at midnight",
              style: TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbeehCard(BuildContext context, Map<String, dynamic> item) {
    final int current = item['currentCount'];
    final int total = item['targetCount'];
    final bool isCompleted = current >= total;
    const Color mintGreen = Color(0xFF10B981);

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F1D),
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, 
                          color: mintGreen, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          "Completed",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mintGreen,
                          ),
                        ),
                      ]
                    ],
                  ),
                  
                  const SizedBox(height: 8),

                  // Stats Text
                  if (!isCompleted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Goal",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "$current / $total",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else
                     Text(
                        "Today's Goal: $total",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                     ),

                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: current / (total == 0 ? 1 : total),
                      backgroundColor: const Color(0xFFF1F3F4),
                      valueColor: const AlwaysStoppedAnimation(mintGreen),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Right Content: Counter Button + Delete Icon
            Column(
              children: [
                // The Circular Counter Button
                GestureDetector(
                  onTap: () {
                     context.read<ZikrProvider>().updateCount(item['id'], current + 1);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? mintGreen : const Color(0xFFE8F5E9),
                      border: isCompleted 
                        ? null 
                        : Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        "$current",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.white : mintGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Trash Icon
                GestureDetector(
                  onTap: () {
                    // Optional: Confirm delete before removing
                    context.read<ZikrProvider>().deleteZikr(item['id']);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                )
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
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: "Target Count",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<ZikrProvider>().addZikr(
                  nameController.text,
                  int.tryParse(targetController.text) ?? 100,
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Mint green
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
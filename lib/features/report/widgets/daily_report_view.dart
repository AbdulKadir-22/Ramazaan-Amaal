import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../home/providers/daily_progress_provider.dart';
import '../../zikr/providers/zikr_provider.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/share_util.dart';
import '../../dua/providers/dua_provider.dart';
import 'package:screenshot/screenshot.dart';


class DailyReportView extends StatefulWidget {
  const DailyReportView({super.key});

  @override
  State<DailyReportView> createState() => _DailyReportViewState();
}

class _DailyReportViewState extends State<DailyReportView> {
  late TextEditingController _notesController;
  bool _isNotesDirty = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DailyProgressProvider>();
    _notesController = TextEditingController(text: provider.notes ?? "");
    _notesController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final provider = context.read<DailyProgressProvider>();
    final currentSaved = provider.notes ?? "";
    setState(() {
      _isNotesDirty = _notesController.text != currentSaved;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyProgressProvider>();
    
    final totalSalah = 5;
    var completedSalah = 0;
    if (provider.isSalahCompleted('Fajr')) completedSalah++;
    if (provider.isSalahCompleted('Dhuhr')) completedSalah++;
    if (provider.isSalahCompleted('Asr')) completedSalah++;
    if (provider.isSalahCompleted('Maghrib')) completedSalah++;
    if (provider.isSalahCompleted('Isha')) completedSalah++;
    
    double completionPercentage = (completedSalah / totalSalah);

    // Calculate Duas completion
    final duaProvider = context.watch<DuaProvider>();
    final totalDuas = duaProvider.allDuas.length; 
    int completedDuas = 0;
    for (var dua in duaProvider.allDuas) {
      if (provider.isDuaDone(dua.title)) completedDuas++;
    }


    // Sync Zikr to DailyRecord for historical tracking
    final zikrProvider = context.read<ZikrProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.syncZikr(zikrProvider.zikrList);
    });

    return Screenshot(
      controller: ShareUtil.screenshotController,
      child: Container(
        color: const Color(0xFFFDFAF6), // Match scaffold background
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          child: Column(
            children: [
            _buildCircularProgress(completionPercentage, completedSalah, totalSalah),
            const SizedBox(height: 30),
            
            Row(
              children: [
                 Expanded(child: _buildSimpleInfoCard(
                   title: "Tilawat", 
                   icon: Icons.menu_book_outlined, 
                   value: "${provider.tilawatPages}",
                   unit: "Pages"
                 )),
                 const SizedBox(width: 12),
                 Expanded(child: _buildSimpleInfoCard(
                   title: "Nawafil", 
                   icon: Icons.auto_awesome_outlined, 
                   value: "${provider.calculateExtraSalahDone()}",
                   unit: "/4"
                 )),
                 const SizedBox(width: 12),
                 Expanded(child: _buildSimpleInfoCard(
                   title: "Duas", 
                   icon: Icons.front_hand_outlined, 
                   value: "$completedDuas",
                   unit: "Recited"
                 )),
              ],
            ),
        const SizedBox(height: 16),
        
        const SizedBox(height: 16),
        
        // Daily Reflection (Self Control)
        _buildReflectionCard(provider),
        const SizedBox(height: 16),

        // Zikr & Duas
        _buildZikrCard(context),
        const SizedBox(height: 16),

        // Notes Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily Notes / Journal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: "Write your thoughts, duas, or reflections...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                  fillColor: const Color(0xFFFAFAFA),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              if (_isNotesDirty)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<DailyProgressProvider>().updateNotes(_notesController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notes saved successfully!"),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      FocusScope.of(context).unfocus(); // Close keyboard
                      // Force dirty check after save (though provider update might trigger rebuild, this ensures local state is sync)
                      setState(() {
                        _isNotesDirty = false;
                      });
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final text = "My Islamic Daily Progress:\n"
                           "- Salah: ${(completionPercentage * 100).toInt()}%\n"
                           "- Tilawat: ${provider.tilawatPages} Pages\n"
                           "Shared via ${AppConstants.appName}";
              
              try {
                final uint8list = await ShareUtil.screenshotController.capture();
                if (uint8list != null) {
                  final directory = await getTemporaryDirectory();
                  final imagePath = await File('${directory.path}/daily_report_${DateTime.now().millisecondsSinceEpoch}.png').create();
                  await imagePath.writeAsBytes(uint8list);

                  await Share.shareXFiles(
                    [XFile(imagePath.path)],
                    text: text,
                  );
                } else {
                  await ShareUtil.shareText(text);
                }
              } catch (e) {
                debugPrint('Error sharing report: $e');
                await ShareUtil.shareText(text);
              }
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text("Share My Progress"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress(double value, int completed, int total) {
    return Column(
      children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 180, height: 180, 
            child: CircularProgressIndicator(
              value: value, 
              strokeWidth: 16, 
              backgroundColor: const Color(0xFFE8F5E9), 
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryDark), 
              strokeCap: StrokeCap.round
            )
          ),
          Text("${(value * 100).toInt()}%", 
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textDark))
        ]),
        const SizedBox(height: 24),
        Text("Today $completed/$total Salah Completed", 
          style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSimpleInfoCard({required String title, required IconData icon, required String value, required String unit}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const TextSpan(text: " "),
                TextSpan(text: unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4C8C74))),
              ]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(DailyProgressProvider provider) {
    // List of reflection keys from AppConstants
    final reflectionKeys = AppConstants.reflectionKeys;

    int completed = 0;
    for (var key in reflectionKeys) {
      if (provider.isReflectionDone(key)) completed++;
    }

    return Column(
      children: [
        Row(children: [
          const Icon(Icons.visibility_outlined, size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          const Text("Self Reflection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 12),
        Container(
           padding: const EdgeInsets.symmetric(vertical: 8),
           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
           child: Column(
             children: reflectionKeys.map((key) {
               bool isDone = provider.isReflectionDone(key);
               String label = key;
               if (key == AppConstants.reflectionLying) label = "Avoided Lying(Jhoot)";
               if (key == AppConstants.reflectionBackbiting) label = "Avoided Backbiting(Gheebat)";
               if (key == AppConstants.reflectionGaze) label = "Lowered Gaze(Bad Nazri)";
               if (key == AppConstants.reflectionArgument) label = "Avoided Argument(Jhagda)";
               if (key == AppConstants.reflectionNegativeThoughts) label = "Negative Thoughts(Bura Khayal)";

               return Column(
                 children: [
                   ListTile(
                    dense: true,
                    title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDone ? AppColors.textDark : Colors.grey)),
                    trailing: Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.blue.withOpacity(0.2)),
                   ),
                   if (key != reflectionKeys.last) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF5F5F5)),
                 ],
               );
             }).toList(),
           ),
        ),
      ],
    );
  }

  Widget _buildZikrCard(BuildContext context) {
    final zikrProvider = context.watch<ZikrProvider>();
    final zikrs = zikrProvider.zikrList;

    // Show only active zikrs or top 3
    final activeZikrs = zikrs.where((z) => (z['currentCount'] as int) > 0).take(3).toList();
    if (activeZikrs.isEmpty && zikrs.isNotEmpty) {
      // If none started, show top 2 items from list
      activeZikrs.addAll(zikrs.take(2));
    }

    return Column(
      children: [
        Row(children: [
          const Icon(Icons.list_alt, size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          const Text("Zikr & Duas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Column(children: [
            if (zikrs.isEmpty)
               const Center(child: Text("No Zikr added yet", style: TextStyle(color: Colors.grey)))
            else
               ...zikrs.map((z) => Padding(
                 padding: const EdgeInsets.only(bottom: 12.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(z['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 15)),
                     Text("${z['currentCount']} / ${z['targetCount']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4C8C74))),
                   ],
                 ),
               )),
          ]),
        ),
      ],
    );
  }

  Widget _buildZikrProgress(String title, String subtitle, int current, int total) {
    bool isComplete = current >= total && total > 0;
    return Row(children: [
      Container(width: 4, height: 36, decoration: BoxDecoration(color: isComplete ? const Color(0xFF10B981) : Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1F1D), fontSize: 14)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11))])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isComplete ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)), child: Text("$current/$total", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isComplete ? const Color(0xFF10B981) : Colors.grey))),
    ]);
  }
}

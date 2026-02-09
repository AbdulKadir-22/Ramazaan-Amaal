import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zikr_provider.dart'; // Ensure this path is correct

class ZikrDetailScreen extends StatefulWidget {
  final Map<String, dynamic> zikrData;

  const ZikrDetailScreen({super.key, required this.zikrData});

  @override
  State<ZikrDetailScreen> createState() => _ZikrDetailScreenState();
}

class _ZikrDetailScreenState extends State<ZikrDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _goalController;
  late TextEditingController _countController;
  
  // Specific colors from your design file
  final Color _mintGreen = const Color(0xFF10B981);
  final Color _darkText = const Color(0xFF1A1F1D);
  final Color _bgWarmWhite = const Color(0xFFFDFAF6);

  String? _reminderTime;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with passed data
    _nameController = TextEditingController(text: widget.zikrData['name']);
    _goalController = TextEditingController(text: widget.zikrData['targetCount'].toString());
    _countController = TextEditingController(text: widget.zikrData['currentCount'].toString());
    _reminderTime = widget.zikrData['reminderTime']; // Format: "HH:MM" or null

    _calculateProgress();

    // Listen to changes to update the top card progress bar in real-time
    _countController.addListener(_calculateProgress);
    _goalController.addListener(_calculateProgress);
  }

  void _calculateProgress() {
    int current = int.tryParse(_countController.text) ?? 0;
    int total = int.tryParse(_goalController.text) ?? 1;
    if (total == 0) total = 1;
    
    setState(() {
      _currentProgress = (current / total).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    TimeOfDay initial = TimeOfDay.now();
    
    // Parse existing time if available
    if (_reminderTime != null && _reminderTime!.contains(":")) {
      final parts = _reminderTime!.split(":");
      initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _mintGreen,
            colorScheme: ColorScheme.light(primary: _mintGreen),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format as HH:MM
      final formattedTime = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _reminderTime = formattedTime;
      });
    }
  }

  void _saveChanges() {
    final String newName = _nameController.text;
    final int newTarget = int.tryParse(_goalController.text) ?? 100;
    final int newCount = int.tryParse(_countController.text) ?? 0;

    // Call Provider Update Method
    // NOTE: You need to ensure your ZikrProvider has an `updateZikr` method 
    // that accepts these parameters.
    context.read<ZikrProvider>().updateZikr(
      widget.zikrData['id'], 
      newName, 
      newTarget, 
      newCount,
      _reminderTime
    );

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Changes saved successfully"),
        backgroundColor: _mintGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteZikr() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Zikr?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<ZikrProvider>().deleteZikr(widget.zikrData['id']);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWarmWhite, // Matches 0xFFFDFAF6
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.zikrData['name'],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. Top Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Current Zikr",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // The Name in the Card (Reacts to controller input)
                            SizedBox(
                              width: 200,
                              child: Text(
                                _nameController.text.isEmpty ? "Zikr Name" : _nameController.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // The Green Badge Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9), // Light mint bg
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified, 
                            color: _mintGreen, 
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Big Stats
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _countController.text.isEmpty ? "0" : _countController.text,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _darkText,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, left: 4),
                          child: Text(
                            "/ ${_goalController.text}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${(_currentProgress * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _mintGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _currentProgress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F3F4),
                        valueColor: AlwaysStoppedAnimation(_mintGreen),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Keep going, you are doing great!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. Details Section Title
              Text(
                "Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 20),

              // 3. Name Input
              const Text(
                "Name",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(controller: _nameController),

              const SizedBox(height: 20),

              // 4. Goal & Count Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Daily Goal",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _goalController, 
                          isNumber: true
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Count",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _countController, 
                          isNumber: true
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. Daily Reminder Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm, 
                        color: Color(0xFF1B5E20), 
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Reminder",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _reminderTime ?? "No time set",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickTime,
                      child: Text(
                        "Change time",
                        style: TextStyle(
                          color: _mintGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 6. Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mintGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 7. Delete Link
              Center(
                child: TextButton(
                  onPressed: _deleteZikr,
                  child: Text(
                    "Delete Zikr",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    bool isNumber = false
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (val) {
        setState(() {}); // Triggers redraw so top card updates immediately
      },
      style: TextStyle(fontWeight: FontWeight.w600, color: _darkText),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _mintGreen),
        ),
      ),
    );
  }
}
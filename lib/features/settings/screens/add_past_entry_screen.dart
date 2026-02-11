import 'package:flutter/material.dart';
import 'package:ramazaan_tracker/core/services/storage_service.dart';
import 'package:ramazaan_tracker/features/home/models/daily_record.dart';
import 'package:provider/provider.dart';
import 'package:ramazaan_tracker/features/zikr/providers/zikr_provider.dart';

class AddPastEntryScreen extends StatefulWidget {
  const AddPastEntryScreen({super.key});

  @override
  State<AddPastEntryScreen> createState() => _AddPastEntryScreenState();
}

class _AddPastEntryScreenState extends State<AddPastEntryScreen> {
  final StorageService _storage = StorageService();
  String _selectedType = 'Salah';
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  DailyRecord? _record;
  
  final TextEditingController _tilawatController = TextEditingController();
  final Map<String, TextEditingController> _zikrControllers = {};

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access provider after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecord();
    });
  }

  void _loadRecord() {
    setState(() {
      _record = _storage.getDailyRecord(_selectedDate) ?? DailyRecord.empty(_selectedDate);
      _tilawatController.text = _record!.tilawatPages.toString();
      
      // Get user-defined zikrs from provider
      final zikrProvider = context.read<ZikrProvider>();
      final userZikrs = zikrProvider.zikrList;
      
      // Initialize Zikr controllers
      _zikrControllers.clear();
      
      // First, add all user-defined zikrs
      for (var z in userZikrs) {
        final name = z['name'] as String;
        // If the record has a count for this zikr, use it, otherwise 0
        final count = _record!.zikr[name] ?? 0;
        _zikrControllers[name] = TextEditingController(text: count.toString());
      }
      
      // Also add any zikrs that are in the record but NOT in the current userZikrs (legacy data)
      _record!.zikr.forEach((key, value) {
        if (!_zikrControllers.containsKey(key)) {
          _zikrControllers[key] = TextEditingController(text: value.toString());
        }
      });
    });
  }

  Future<void> _saveRecord() async {
    if (_record == null) return;

    // Sync values from all controllers
    _record!.tilawatPages = int.tryParse(_tilawatController.text) ?? 0;
    _zikrControllers.forEach((key, controller) {
      _record!.zikr[key] = int.tryParse(controller.text) ?? 0;
    });

    await _storage.saveDailyRecord(_record!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entry saved successfully!"), backgroundColor: Color(0xFF10B981)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Past Entry",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Category", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF10B981)),
                  items: <String>['Salah', 'Tilawat', 'Zikr', 'Roza', 'Reflection'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Select Date", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: Color(0xFF10B981)),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _loadRecord();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF10B981), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _record == null 
                ? const Center(child: CircularProgressIndicator())
                : _buildCategoryForm(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Save Entry", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryForm() {
    switch (_selectedType) {
      case 'Salah':
        return _buildSalahForm();
      case 'Tilawat':
        return _buildTilawatForm();
      case 'Zikr':
        return _buildZikrForm();
      case 'Roza':
        return _buildRozaForm();
      case 'Reflection':
        return _buildReflectionForm();
      default:
        return const Center(child: Text("Select a category to start"));
    }
  }

  Widget _buildSalahForm() {
    final mainPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Taraweeh'];
    final extraPrayers = ['Tahajjud', 'Ishraq', 'Chasht', 'Awwabin'];

    return ListView(
      children: [
        const Text("Mandatory & Taraweeh", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        ...mainPrayers.map((p) => CheckboxListTile(
          title: Text(p),
          value: _record!.salah[p] ?? false,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) => setState(() => _record!.salah[p] = val!),
        )),
        const SizedBox(height: 16),
        const Text("Nawafil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        ...extraPrayers.map((p) => CheckboxListTile(
          title: Text(p),
          value: _record!.extraSalah[p] ?? false,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) => setState(() => _record!.extraSalah[p] = val!),
        )),
      ],
    );
  }

  Widget _buildTilawatForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pages Read", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        TextField(
          controller: _tilawatController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter number of pages",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildZikrForm() {
    return ListView(
      children: _zikrControllers.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
            SizedBox(
              width: 100,
              child: TextField(
                controller: e.value,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRozaForm() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Roza (Fasted)"),
          value: _record!.rozaNiyat,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) => setState(() => _record!.rozaNiyat = val),
        ),
        SwitchListTile(
          title: const Text("Suhoor Niyat"),
          value: _record!.suhoorNiyat,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) => setState(() => _record!.suhoorNiyat = val),
        ),
      ],
    );
  }

  Widget _buildReflectionForm() {
    return ListView(
      children: _record!.selfReflection.keys.map((habit) => CheckboxListTile(
        title: Text(habit),
        value: _record!.selfReflection[habit] ?? false,
        activeColor: const Color(0xFF10B981),
        onChanged: (val) => setState(() => _record!.selfReflection[habit] = val!),
      )).toList(),
    );
  }
}

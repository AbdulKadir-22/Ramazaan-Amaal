import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/dua_model.dart';

class DuaProvider extends ChangeNotifier {
  List<DuaModel> _duas = [];
  List<DuaModel> _filteredDuas = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<DuaModel> get duas => _searchQuery.isEmpty ? _duas : _filteredDuas;
  List<DuaModel> get allDuas => _duas;
  bool get isLoading => _isLoading;

  Future<void> loadDuas() async {
    try {
      final String response = await rootBundle.loadString('assets/data/duas.json');
      final data = await json.decode(response) as List;
      _duas = data.map((e) => DuaModel.fromJson(e)).toList();
      _filteredDuas = _duas;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading duas: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchDuas(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredDuas = _duas;
    } else {
      _filteredDuas = _duas
          .where((dua) =>
              dua.title.toLowerCase().contains(query.toLowerCase()) ||
              dua.translation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

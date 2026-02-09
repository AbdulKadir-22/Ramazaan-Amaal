import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  String? _userName;
  bool _isLoading = false;

  String? get userName => _userName;
  bool get isLoading => _isLoading;
  bool get isUserLoggedIn => _storageService.hasUser;

  // Load user data into state (called on app start)
  void loadUser() {
    _userName = _storageService.getUserName();
    notifyListeners();
  }

  // Save user name and update state
  Future<void> saveUser(String name) async {
    _isLoading = true;
    notifyListeners();

    // Simulate a brief delay for smooth UI feel (optional)
    await Future.delayed(const Duration(milliseconds: 500));

    await _storageService.saveUserName(name);
    _userName = name;
    
    _isLoading = false;
    notifyListeners();
  }
}
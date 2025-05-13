import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AuthViewModel with ChangeNotifier {
  String? _pinCode;
  bool _isAuthenticated = false;
  File? _profileImage;
  bool _isAdmin = false;
  String? _userEmail;

  String? get pinCode => _pinCode;
  bool get isPinSet => _pinCode != null;
  bool get isAuthenticated => _isAuthenticated;
  File? get profileImage => _profileImage;
  bool get isAdmin => _isAdmin;
  String? get userEmail => _userEmail;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _pinCode = prefs.getString('app_pin');
    final imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      _profileImage = File(imagePath);
    }
    _isAdmin = prefs.getBool('is_admin') ?? false;
    _userEmail = prefs.getString('user_email');
    notifyListeners();
  }

  Future<bool> setPin(String newPin) async {
    if (newPin.length != 4) return false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin', newPin);
      _pinCode = newPin;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('PIN kodni saqlashda xatolik: $e');
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    if (_pinCode == null) return false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('app_pin');
      if (savedPin == pin) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('PIN tekshirishda xatolik: $e');
      return false;
    }
  }

  Future<void> setProfileImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', imageFile.path);
      _profileImage = imageFile;
      notifyListeners();
    } catch (e) {
      debugPrint('Profil rasmini saqlashda xatolik: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_pin');
      _pinCode = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Chiqishda xatolik: $e');
    }
  }

  Future<void> clearPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_pin');
      _pinCode = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('PIN kodni tozalashda xatolik: $e');
    }
  }
}
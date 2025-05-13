import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _phoneKey = 'user_phone';

  static Future<bool> registerPhone(String phone) async {
    if (phone.length != 9 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
    return true;
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<bool> isRegistered() async {
    return (await getPhone()) != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }
}
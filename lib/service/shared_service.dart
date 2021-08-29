import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("login_details") != null ? true : false;
  }

  static Future<String> loginDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("login_details") != null
        ? prefs.getString("login_details")
        : null;
  }

  static Future<void> setLoginDetails(String username) async {
  final prefs = await SharedPreferences.getInstance();
    prefs.setString("login_details", username != null ? username : null);
  }

  static Future<void> logout(BuildContext context) async {
    await setLoginDetails(null);
    Navigator.of(context).pushReplacementNamed('/login');
  }
}

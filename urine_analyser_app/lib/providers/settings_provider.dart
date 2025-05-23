import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _currentUser = 'Ben';
  String _ipAddress = '172.20.124.54:5000';

  String get currentUser => _currentUser;
  String get ipAddress {
    // Ensure the IP address starts with http:// or https://
    if (!_ipAddress.startsWith('http://') &&
        !_ipAddress.startsWith('https://')) {
      return 'http://$_ipAddress';
    }
    return _ipAddress;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = prefs.getString('currentUser') ?? 'Ben';
    _ipAddress = prefs.getString('ipAddress') ?? '172.20.124.54:5000';
    notifyListeners();
  }

  Future<void> setCurrentUser(String user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', user);
    notifyListeners();
  }

  Future<void> setIpAddress(String ip) async {
    _ipAddress = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', ip);
    notifyListeners();
  }
}

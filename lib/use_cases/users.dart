import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Future<int> getLoggedInUserId() async {
  var prefs = await SharedPreferences.getInstance();
  int userId = prefs.getInt('userId') ?? null;
  return userId;
}

Future<String> getAuthToken() async {
  var prefs = await SharedPreferences.getInstance();
  String authToken = prefs.getString('authToken') ?? null;
  return authToken;
}

void resetLoggedInUserID() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('userId', null);
}

void resetAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('authToken', null);
}

void setAuthToken(String authToken) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('authToken', authToken);
}

void setUserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('userId', userId);
}


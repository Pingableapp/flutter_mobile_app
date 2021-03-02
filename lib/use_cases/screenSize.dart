import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Future<int> getScreenWidth() async {
  var prefs = await SharedPreferences.getInstance();
  int screenWidth = prefs.getInt('screenWidth') ?? null;
  return screenWidth;
}

Future<int> getScreenHeight() async {
  var prefs = await SharedPreferences.getInstance();
  int screenHeight = prefs.getInt('screenHeight') ?? null;
  return screenHeight;
}

void setScreenWidth(int screenWidth) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('screenWidth', screenWidth);
}

void setScreenHeight(int screenHeight) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('screenHeight', screenHeight);
}

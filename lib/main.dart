import 'package:flutter/material.dart';
import 'package:pingable/views/home.dart';
import 'package:pingable/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Widget _defaultHome = new Login();

  // Get result of the login function.
  // obtain shared preferences
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId') ?? null;
  final authToken = prefs.getString('authToken') ?? null;

  if (userId != null && authToken != null) {
    _defaultHome = new Home(userId, authToken);
  }

  runApp(MaterialApp(
    title: 'Flutter',
    home: _defaultHome,
    // routes: <String, WidgetBuilder>{
    //   // Set routes for using the Navigator.
    //   '/home': (BuildContext context) => new Home(),
    //   '/login': (BuildContext context) => new Login(),
    // },
  ));
}

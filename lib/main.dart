import 'package:flutter/material.dart';
import 'package:pingable/shared/sharedPref.dart';
import 'package:pingable/views/accounts.dart';
import 'package:pingable/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Widget _defaultHome = new Login();
  String _defaultRoute = "/accounts";

  // Get result of the login function.
  // obtain shared preferences
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId') ?? null;
  final authToken = prefs.getString('authToken') ?? null;


  SharedPref sharedPref = SharedPref();
  final user = await sharedPref.read("user");

  if (userId != null && authToken != null && user != null) {
    _defaultRoute = "/home";
  }

  runApp(MaterialApp(
    title: 'Flutter',
    // home: _defaultHome,
    initialRoute: _defaultRoute,
    routes: <String, WidgetBuilder>{
      // Set routes for using the Navigator.
      '/home': (BuildContext context) => new Home(),
      '/accounts': (BuildContext context) => new Accounts(),
    },
  ));
}

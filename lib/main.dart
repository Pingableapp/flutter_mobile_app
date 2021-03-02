import 'package:flutter/material.dart';
import 'package:pingable/api/appVersion.dart' as appVersionAPI;
import 'package:pingable/shared/sharedPref.dart';
import 'package:pingable/use_cases/users.dart' as usersUseCase;
import 'package:pingable/views/accounts.dart';
import 'package:pingable/views/home.dart';
import 'package:pingable/views/update.dart';

Future<String> defaultRoute() async {
  double currentVersion = 0.1;
  double minimumVersion = await appVersionAPI.getAppVersion();
  if (currentVersion < minimumVersion) {
    return "/update";
  }

  String _defaultRoute = "/accounts";

  WidgetsFlutterBinding.ensureInitialized();
  int userId = await usersUseCase.getLoggedInUserId();
  String authToken = await usersUseCase.getAuthToken();

  SharedPref sharedPref = SharedPref();
  final user = await sharedPref.read("user");

  if (userId != null && authToken != null && user != null) {
    _defaultRoute = "/home";
  }

  return _defaultRoute;
}

void main() async {
  runApp(
    MaterialApp(
      title: 'Flutter',
      initialRoute: await defaultRoute(),
      routes: <String, WidgetBuilder>{
        '/update': (BuildContext context) => new Update(),
        '/home': (BuildContext context) => new Home(),
        '/accounts': (BuildContext context) => new Accounts(),
      },
    ),
  );
}

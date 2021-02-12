// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pingable/api/users.dart';

import 'package:pingable/main.dart';
import 'package:pingable/models/user.dart';

void main() async {
  // TODO: Figure out how to swap api endpoint ip from 10.0.2.2 to localhost

    // Build our app and trigger a frame.
    int userID = 27;
    User user = await getUser(userID);
    print(user.firstName);
}

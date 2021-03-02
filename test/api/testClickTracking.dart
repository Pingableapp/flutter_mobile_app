// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:pingable/api/clickTracking.dart';

void main() async {
    int userId = 39;
    String actionId = "add_friend";
    String actionType = "click";
    int screenWidth = 300;
    int screenHeight = 800;
    String additionalInfo = "Extra info here";
    await recordClickTrackingEvent(userId, actionId, actionType, screenWidth, screenHeight, additionalInfo);
}

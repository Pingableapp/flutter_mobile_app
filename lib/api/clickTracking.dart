import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';

Future recordClickTrackingEvent(
    int userId, String actionId, String actionType, int screenWidth, int screenHeight, String additionalInfo) async {

  var postUrl = '$apiEndpoint/click_tracking';
  String data = '''
  {
    "user_id": $userId,
    "action_id": "$actionId",
    "action_type": "$actionType",
    "screen_width": $screenWidth,
    "screen_height": $screenHeight,
    "additional_info": "$additionalInfo"
  }''';
  http.Response resPost = await http.post(postUrl, body: data);
}

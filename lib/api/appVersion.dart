import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';

Future<double> getAppVersion() async {
  // Check to see if verification code is valid & retrieve auth token
  var getUrl = '$apiEndpoint/app_version';
  http.Response resGet = await http.get(getUrl);

  // Ensure proper status code
  if (resGet.statusCode != 200) {
    return 0.0;
  }

  return jsonDecode(resGet.body)["minimum_app_version"];
}

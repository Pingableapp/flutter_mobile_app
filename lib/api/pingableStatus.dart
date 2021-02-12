import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:pingable/models/status.dart';

Future<List<Status>> getPingableAllStatus(int userId) async {
  List<Status> statusList = [];


  // Check to see if verification code is valid & retrieve auth token
  var getUrl = '$apiEndpoint/users/$userId/statuses';
  http.Response resGet = await http.get(getUrl);

  // Ensure proper status code
  if (resGet.statusCode != 200) {
    return statusList;
  }

  var statuses = jsonDecode(resGet.body)["results"];

  for (var i = 0; i < statuses.length; i++) {
    statusList.add(new Status(
      statuses[i]["status_id"],
      statuses[i]["user_id"],
      statuses[i]["status"],
      statuses[i]["group_id"],
      statuses[i]["type"],
      statuses[i]["end_time"],
    ));
  }

  return statusList;
}

Future<bool> updatePingableStatus(int statusID, int statusCode) async {
  // Check to see if verification code is valid & retrieve auth token
  var getUrl = '$apiEndpoint/statuses/$statusID';
  String data = '{"status":"${statusCode.toString()}"}';
  http.Response resPut = await http.put(getUrl, body: data);

  // Ensure proper status code
  if (resPut.statusCode != 200) {
    return false;
  }

  return true;
}

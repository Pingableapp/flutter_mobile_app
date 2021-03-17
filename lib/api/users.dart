import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:pingable/models/user.dart';

Future<User> getUser(int userId) async {
  // Check to see if verification code is valid & retrieve auth token
  var getUrl = '$apiEndpoint/users/$userId';
  http.Response resGet = await http.get(getUrl);

  // Ensure proper status code
  if (resGet.statusCode != 200) {
    return null;
  }

  var user = jsonDecode(resGet.body)["results"];
  String firstName = user["first_name"];
  String lastName = user["last_name"];
  String phoneNumber = user["phone_number"];
  int id = user["id"];

  return new User(id, firstName, lastName, phoneNumber);
}


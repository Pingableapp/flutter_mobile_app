import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';



Future acceptFriendRequest(int sendingUserId, int receivingUserId) async {
  var putUrl = '$apiEndpoint/users/$receivingUserId/friend_requests';

  String data = '{"sending_user_id":"$sendingUserId"}';
  http.Response resPut = await http.put(putUrl, body: data);
  var results = jsonDecode(resPut.body);
}

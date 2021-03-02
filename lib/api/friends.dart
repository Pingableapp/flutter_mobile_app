import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:pingable/functions/strings.dart';
import 'package:pingable/models/friend.dart';
import 'package:pingable/models/friendRequest.dart';

Future sendInviteToPingable(int sendingUserId, String receivingPhoneNumber) async {
  var postUrl = '$apiEndpoint/one_offs/invite_to_pingable';

  String data = '{'
      '"sending_user_id":"$sendingUserId",'
      '"receiving_phone_number": "$receivingPhoneNumber"'
      '}';
  http.Response resPost = await http.post(postUrl, body: data);
  var results = jsonDecode(resPost.body);
}

Future sendFriendRequest(int sendingUserId, int receivingUserId) async {
  var postUrl = '$apiEndpoint/users/$sendingUserId/friend_requests';

  String data = '{'
      '"sending_user_id":"$sendingUserId",'
      '"receiving_user_id": "$receivingUserId"'
      '}';
  http.Response resPost = await http.post(postUrl, body: data);
  var results = jsonDecode(resPost.body);
}

Future<List<FriendRequest>> getFriendRequests(int userId) async {
  // Check to see if verification code is valid & retrieve auth token
  var getUrl = '$apiEndpoint/users/$userId/friend_requests';
  http.Response resGet = await http.get(getUrl);

  // Ensure proper status code
  if (resGet.statusCode != 200) {
    return [];
  }

  List<FriendRequest> unsortedFriendRequests = [];
  var friends = jsonDecode(resGet.body)["results"];
  for (var i = 0; i < friends.length; i++) {
    int sendingUserId = friends[i]["sending_user_id"];
    String sendingFirstName = friends[i]["sending_first_name"];
    String sendingLastName = friends[i]["sending_last_name"];
    String receivingPhoneNumber = friends[i]["receiving_phone_number"];
    String expirationTimestamp = friends[i]["expiration_timestamp"];

    unsortedFriendRequests.add(
        new FriendRequest(sendingUserId, sendingFirstName, sendingLastName, receivingPhoneNumber, expirationTimestamp));
  }

  return unsortedFriendRequests;
}

Future<List<Friend>> getFriendActivity(int userId) async {
  // Check to see if verification code is valid & retrieve auth token
  var getUrl = '$apiEndpoint/users/$userId/relationships';
  http.Response resGet = await http.get(getUrl);

  // Ensure proper status code
  if (resGet.statusCode != 200) {
    return [];
  }

  List<Friend> unsortedFriendsList = [];
  var friends = jsonDecode(resGet.body)["results"];
  for (var i = 0; i < friends.length; i++) {
    String firstName = capitalize(friends[i]["first_name"]);
    String lastName = capitalize(friends[i]["last_name"]);
    String phoneNumber = friends[i]["phone_number"];
    int relationshipStatus = friends[i]["relationship_status"];
    bool active = friends[i]["availability_status"] == 1;
    int id = friends[i]["id"];

    unsortedFriendsList.add(new Friend(id, firstName, lastName, phoneNumber, relationshipStatus, active));
  }

  return unsortedFriendsList;
}

Future<List<Friend>> getFriendsList(int userId) async {
  if (userId == null) {
    return null;
  }

  // Get list of unsorted friends
  List<Friend> unsortedFriendsList = await getFriendActivity(userId);

  // Sort by first name
  unsortedFriendsList.sort((a, b) => a.firstName.compareTo(b.firstName));
  List<Friend> sortedFriendsList = [];

  // Add active friends from unsortedFriendsList to friendsList
  for (var i = 0; i < unsortedFriendsList.length; i++) {
    if (unsortedFriendsList[i].active) {
      sortedFriendsList.add(unsortedFriendsList[i]);
    }
  }

  // Add inactive friends from unsortedFriendsList to friendsList
  for (var i = 0; i < unsortedFriendsList.length; i++) {
    if (!unsortedFriendsList[i].active) {
      sortedFriendsList.add(unsortedFriendsList[i]);
    }
  }

  return sortedFriendsList;
}

Future<List<Friend>> searchForFriends(String firstName, String lastName) async {
  print("Searching for $firstName $lastName");

  var getUrl = '$apiEndpoint/users?first_name=${firstName.toLowerCase()}';
  http.Response resGet = await http.get(getUrl);

  List<Friend> unsortedFriendsList = [];
  var friends = jsonDecode(resGet.body)["results"];
  for (var i = 0; i < friends.length; i++) {
    String firstName = capitalize(friends[i]["first_name"]);
    String lastName = capitalize(friends[i]["last_name"]);
    String phoneNumber = friends[i]["phone_number"];
    int relationshipStatus = friends[i]["relationship_status"];
    bool active = friends[i]["availability_status"] == 1;
    int id = friends[i]["id"];
    unsortedFriendsList.add(new Friend(id, firstName, lastName, phoneNumber, relationshipStatus, active));
  }
  return unsortedFriendsList;
}

Future<List<Friend>> lookupByPhoneNumbers(List<String> phoneNumbers, int userId) async {
  var postUrl = '$apiEndpoint/one_offs/users_by_phone_number_list';

  String data = '{"user_id":"$userId",'
      '"phone_number_list": ["${phoneNumbers.join('","')}"]}';
  http.Response resPost = await http.post(postUrl, body: data);
  var results = jsonDecode(resPost.body);

  List<Friend> foundFriends = [];
  for (var i = 0; i < results.length; ++i) {
    var currResult = results[i];
    foundFriends.add(
      new Friend(
        currResult["id"],
        currResult["first_name"],
        currResult["last_name"],
        currResult["phone_number"],
        currResult["status"],
        null,
      ),
    );
  }

  return foundFriends;

  // List<Friend> unsortedFriendsList = [];
  // var friends = jsonDecode(resGet.body)["results"];
  // for (var i = 0; i < friends.length; i++) {
  //   String firstName = capitalize(friends[i]["first_name"]);
  //   String lastName = capitalize(friends[i]["last_name"]);
  //   String phoneNumber = friends[i]["phone_number"];
  //   int relationshipStatus = friends[i]["relationship_status"];
  //   bool active = friends[i]["availability_status"] == 1;
  //   int id = friends[i]["id"];
  //   unsortedFriendsList.add(new Friend(
  //       id, firstName, lastName, phoneNumber, relationshipStatus, active));
  // }
  // return unsortedFriendsList;
}

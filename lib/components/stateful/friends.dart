import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:url_launcher/url_launcher.dart';

String capitalize(String string) {
  if (string == null) {
    throw ArgumentError.notNull('string');
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

class Friend {
  final String firstName, lastName, phoneNumber;
  final bool active;

  Friend(this.firstName, this.lastName, this.phoneNumber, this.active);
}

class Friends extends StatefulWidget {
  final int userId;

  Friends(this.userId);

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    fetchCurrentFriends();
    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => fetchCurrentFriends());
  }

  Color getPrimaryColor(bool active) {
    if (active) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  List<Friend> friendsList = [];

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
      bool active = friends[i]["availability_status"] == 1;
      unsortedFriendsList
          .add(new Friend(firstName, lastName, phoneNumber, active));
    }

    return unsortedFriendsList;
  }

  void fetchCurrentFriends() async {
    // Get list of unsorted friends
    List<Friend> unsortedFriendsList = await getFriendActivity(widget.userId);

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

    setState(() {
      friendsList = sortedFriendsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 5.0, left: 5.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Friends",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 5.0),
            height: 75.0,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friendsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      width: 120,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: RaisedButton(
                        color: getPrimaryColor(friendsList[index].active),
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _buildFriendPopupDialog(
                                    context, friendsList[index]),
                          );
                        },
                        child: Align(
                            child: Text(
                                '${friendsList[index].firstName} ${friendsList[index].lastName}')),
                      ));
                }))
      ],
    );
  }
}

Widget _buildFriendPopupDialog(BuildContext context, Friend friend) {
  String isAvailable(bool available) {
    if (available) {
      return "Yes";
    } else {
      return "No";
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  return new AlertDialog(
    title: Text('Contact ${friend.firstName} ${friend.lastName}'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Currently Pingable: ${isAvailable(friend.active)}"),
        Text("Phone number: ${friend.phoneNumber}"),
        RaisedButton(
          onPressed: friend.active
              ? () => _makePhoneCall('tel://${friend.phoneNumber}')
              : null,
          child: const Text('Make phone call'),
        ),
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: const Text('Close'),
      ),
    ],
  );
}

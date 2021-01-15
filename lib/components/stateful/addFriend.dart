import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:pingable/models/friend.dart';
import 'package:pingable/functions/strings.dart';

class AddFriend extends StatefulWidget {
  AddFriend();

  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  bool displayResults = false;

  List<Friend> friendsFound;

  void searchForFriends(String firstName, String lastName) async {
    print("Searching for $firstName $lastName");
    var getUrl = '$apiEndpoint/users?first_name=${firstName.toLowerCase()}';
    http.Response resGet = await http.get(getUrl);
    var results = jsonDecode(resGet.body)["results"];

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

    setState(() {
      friendsFound = unsortedFriendsList;
      displayResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Add a Friend'),
      content: displayResults
          ? Text("Results")
          : SearchFriends(callback: searchForFriends),
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
}

typedef void StringCallback(String firstName, String lastName);

class SearchFriends extends StatelessWidget {
  final StringCallback callback;

  SearchFriends({this.callback});

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 5.0, bottom: 15.0),
          child: TextField(
            textAlign: TextAlign.left,
            controller: firstNameController,
            decoration: InputDecoration(
              hintText: 'First name',
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5.0, bottom: 15.0),
          child: TextField(
            textAlign: TextAlign.left,
            controller: lastNameController,
            decoration: InputDecoration(
              hintText: 'Last name',
            ),
          ),
        ),
        Container(
            child: RaisedButton(
                child: Text(
                  'Search',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  callback(firstNameController.text, lastNameController.text);
                }))
      ],
    ));
  }
}

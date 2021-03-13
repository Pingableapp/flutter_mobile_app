import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/components/stateless/addFriendButton.dart';
import 'package:pingable/components/stateless/friendsList.dart';
import 'package:pingable/models/friend.dart';

class Friends extends StatelessWidget {
  final List<Friend> listOfFriends;
  final int friendRequests;

  Friends({this.listOfFriends, this.friendRequests});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            AddFriendButton(friendRequests: friendRequests)
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          height: 75.0,
          child: FriendsList(
            listOfFriends: filterAcceptedFriends(listOfFriends),
          ),
        ),
      ],
    );
  }
}

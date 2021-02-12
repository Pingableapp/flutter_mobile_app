import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pingable/components/stateless/friendInfo.dart';
import 'package:pingable/models/friend.dart';

class FriendsList extends StatelessWidget {
  final List<Friend> listOfFriends;

  FriendsList({this.listOfFriends});

  Color getPrimaryColor(bool active) {
    if (active) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listOfFriends.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: 120,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: RaisedButton(
                color: getPrimaryColor(listOfFriends[index].active),
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        FriendInfo(friend: listOfFriends[index]),
                  );
                },
                child: Align(
                    child: Text(
                        '${listOfFriends[index].firstName} ${listOfFriends[index].lastName}')),
              ));
        });
  }
}

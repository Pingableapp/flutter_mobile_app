import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/models/friendRequest.dart';

import 'friendRequestListEntry.dart';

typedef void StringCallback(int sendingUserId, String receivingPhoneNumber);

class FriendRequestList extends StatelessWidget {
  final StringCallback callback;
  final List<FriendRequest> friendRequestList;

  FriendRequestList({this.friendRequestList, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      width: 300.0,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: friendRequestList.length,
        itemBuilder: (BuildContext context, int index) {
          return FriendRequestListEntry(
            sendingUserId: friendRequestList[index].sendingUserId,
            sendingFirstName: friendRequestList[index].sendingFirstName,
            sendingLastName: friendRequestList[index].sendingLastName,
            receivingPhoneNumber: friendRequestList[index].receivingPhoneNumber,
            expirationTimestamp: friendRequestList[index].expirationTimestamp,
            callback: callback,
          );
        },
      ),
    );
  }
}

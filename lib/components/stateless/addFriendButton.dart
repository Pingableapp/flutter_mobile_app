import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pingable/components/stateful/addFriendDialog.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;

class AddFriendButton extends StatelessWidget {
  final int friendRequests;

  AddFriendButton({this.friendRequests});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5.0, right: 5.0),
      child: ElevatedButton(
        child: Align(
          child: Text(friendRequests != null && friendRequests > 0
              ? "Add a friend ($friendRequests)"
              : "Add a friend"),
        ),
        onPressed: () {
          clickTrackingUseCase.recordClickTrackingEvent(
              "add_a_friend", "click", "");
          showDialog(
            context: context,
            builder: (BuildContext context) => AddFriendDialog(),
          );
        },
      ),
    );
  }
}

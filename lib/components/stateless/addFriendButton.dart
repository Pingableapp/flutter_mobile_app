import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pingable/components/stateful/addFriendDialog.dart';

class AddFriendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5.0, right: 5.0),
      child: RaisedButton(
          child: Align(
            child: Text("Add a friend"),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AddFriendDialog(),
            );
          }),
    );
  }
}

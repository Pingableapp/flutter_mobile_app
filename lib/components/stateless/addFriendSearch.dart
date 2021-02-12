
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void StringCallback(String firstName, String lastName);

class AddFriendSearchDatabase extends StatelessWidget {
  final StringCallback callback;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  AddFriendSearchDatabase({this.callback});

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

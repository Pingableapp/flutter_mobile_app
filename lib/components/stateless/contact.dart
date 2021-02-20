import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void StringCallback(
    int id, String firstName, String lastName, String phoneNumber);

class Contact extends StatelessWidget {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final int relationshipStatus;
  final StringCallback callback;

  Contact({
    this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.relationshipStatus,
    this.callback,
  });

  Widget selectCommunicationButton(int id, int relationshipStatus) {
    if (id == null) {
      return RaisedButton(
        color: Colors.blue,
        onPressed: () => callback(id, firstName, lastName, phoneNumber),
        child: Text(
          "Invite to Pingable",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }

    switch (relationshipStatus) {
      case 0:
        return RaisedButton(
          color: Colors.blue,
          onPressed: null,
          child: Text(
            "Request sent",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      case 1:
        return RaisedButton(
          color: Colors.blue,
          onPressed: null,
          child: Text(
            "Already added",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      case 2:
        return RaisedButton(
          color: Colors.blue,
          onPressed: null,
          child: Text(
            "Cannot add",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      case 3:
        return RaisedButton(
          color: Colors.blue,
          onPressed: null,
          child: Text(
            "Cannot add",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      default:
        return RaisedButton(
          color: Colors.blue,
          onPressed: () => callback(id, firstName, lastName, phoneNumber),
          child: Text(
            "Send friend request",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("$firstName $lastName"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$phoneNumber"),
               selectCommunicationButton(id, relationshipStatus),
            ],
          )
        ],
      ),
    );
  }
}

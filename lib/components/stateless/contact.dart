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
              RaisedButton(
                color: Colors.blue,
                onPressed: () => callback(id, firstName, lastName, phoneNumber),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

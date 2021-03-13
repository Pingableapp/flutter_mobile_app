import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/components/stateless/contact.dart';
import 'package:pingable/models/friend.dart';

typedef void StringCallback(
    int id, String firstName, String lastName, String phoneNumber);


class AddFriendFromContacts extends StatelessWidget {
  final StringCallback callback;
  final List<Friend> contactList;

  AddFriendFromContacts({this.contactList, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .6,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: contactList.length,
        itemBuilder: (BuildContext context, int index) {
          return Contact(
            id: contactList[index].id,
            firstName: contactList[index].firstName,
            lastName: contactList[index].lastName,
            phoneNumber: contactList[index].phoneNumber,
            relationshipStatus: contactList[index].relationshipStatus,
            callback: callback,
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/components/stateless/contact.dart';
import 'package:pingable/models/friend.dart';

typedef void FriendCallback(int id, String firstName, String lastName, String phoneNumber);
typedef void StringCallback(String text);

class AddFriendFromContacts extends StatelessWidget {
  final FriendCallback callbackContactClick;
  final StringCallback callbackSearchTextChange;
  final List<Friend> contactList;
  final TextEditingController searchTextController;

  AddFriendFromContacts({
    this.searchTextController,
    this.contactList,
    this.callbackContactClick,
    this.callbackSearchTextChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5.0, bottom: 15.0),
          child: TextField(
            textAlign: TextAlign.left,
            controller: searchTextController,
            decoration: InputDecoration(
              hintText: 'Search by name',
            ),
            onChanged: callbackSearchTextChange,
          ),
        ),
        Container(
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
                callback: callbackContactClick,
              );
            },
          ),
        ),
      ],
    );
  }
}

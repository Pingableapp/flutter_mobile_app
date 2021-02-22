import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/api/friends.dart';
import 'package:pingable/components/stateless/addFriendFromContacts.dart';
import 'package:pingable/components/stateless/addFriendSearch.dart';
import 'package:pingable/models/friend.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:pingable/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFriendDialog extends StatefulWidget {
  AddFriendDialog();

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

extension E on String {
  String lastChars(int n) => substring(length - n);
}

List<Friend> mergeFriendLists(List<Friend> listOne, List<Friend> listTwo) {
  // Given two lists of friends, combine them. On conflicts, use listOne's entry
  Map listTwoNumbersMap = {};
  for (int i = 0; i < listTwo.length; ++i) {
    Friend listTwoFriend = listTwo[i];
    String listTwoFriendNumber = listTwoFriend.phoneNumber
        .replaceAll(RegExp('[^0-9]'), '')
        .lastChars(10);
    listTwoNumbersMap[listTwoFriendNumber] = listTwoFriend;
  }

  // If any of listOne's entries appear in the listTwo map, add the listOne
  // entry to combinedFriends and remove the listTwo entry from the map.
  List<Friend> combinedFriends = [];
  for (int i = 0; i < listOne.length; ++i) {
    Friend listOneFriend = listOne[i];
    String listOneFriendNumber = listOneFriend.phoneNumber
        .replaceAll(RegExp('[^0-9]'), '')
        .lastChars(10);
    if (listOneFriendNumber.contains(listOneFriendNumber)) {
      combinedFriends.add(listOneFriend);
      listTwoNumbersMap.remove(listOneFriendNumber);
    }
  }

  listTwoNumbersMap.forEach((key, value) => combinedFriends.add(value));
  return combinedFriends;
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  bool loadingContacts = true;
  bool displayResults = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  String currentScreen;

  List<Friend> contactList;

  // List<Friend> friendsFound;

  // searchForFriendsAndUpdate(String firstName, String lastName) async {
  //   List<Friend> _friendsFound;
  //   _friendsFound = await searchForFriendsAndUpdate(firstName, lastName);
  //
  //   setState(() {
  //     friendsFound = _friendsFound;
  //     displayResults = true;
  //   });
  // }

  Future displayScreen(String screen) async {
    String _currentScreen = screen;
    bool _loadingContacts = true;

    if (screen == "contacts") {
      // Ensure we have proper access to contacts
      var status = await Permission.contacts.status;
      if (status.isUndetermined) {
        var permissionRequest = await Permission.contacts.request();
        status = await Permission.contacts.status;
      }

      // If we have access, fetch contacts list and retrieve
      // matching data form pingable API
      if (await Permission.contacts.isGranted) {
        Iterable<Contact> phoneContactList =
        await ContactsService.getContacts(withThumbnails: false);

        // Create friend objects w/ pingable API data + phone data
        List<Friend> updatedContactList = [];
        List<String> phoneNumbers = [];
        for (var entry in phoneContactList) {
          int id;
          String firstName = entry.givenName;
          String lastName = entry.familyName;
          String phoneNumber = entry.phones.toList()[0].value;
          int relationshipStatus = 0;

          updatedContactList.add(
            new Friend(
                id, firstName, lastName, phoneNumber, relationshipStatus, null),
          );
          phoneNumbers.add(phoneNumber);
        }

        // Get data about friends from Pingable API
        var prefs = await SharedPreferences.getInstance();
        int userId = prefs.getInt('userId') ?? null;
        var existingContactListFriends =
        await lookupByPhoneNumbers(phoneNumbers, userId);
        updatedContactList =
            mergeFriendLists(existingContactListFriends, updatedContactList);
        updatedContactList = User.sortUserListFirstLast(updatedContactList);

        setState(() {
          contactList = updatedContactList;
        });
        _loadingContacts = false;
      } else {
        // Failed to verify access to phone contacts
        _currentScreen = "needContactAccess";
      }
    }

    setState(() {
      loadingContacts = _loadingContacts;
      currentScreen = _currentScreen;
    });
  }

  addFriend(int id, String firstName, String lastName,
      String phoneNumber) async {
    // Find the user we are looking for
    int contactIndex;
    for (int i = 0; i < contactList.length; ++i) {
      Friend currContact = contactList[i];
      if (currContact.id == id &&
          currContact.firstName == firstName &&
          currContact.lastName == lastName &&
          currContact.phoneNumber == phoneNumber) {
        contactIndex = i;
        break;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? null;

    if (id == null) {
      // User doesn't exist yet - send invite
      await sendInviteToPingable(userId, contactList[contactIndex].phoneNumber);
      setState(() {
        contactList[contactIndex].relationshipStatus = 0;
        contactList[contactIndex].id = -1;
      });
      print("$firstName $lastName $phoneNumber -> Sending pingable invite");
    } else {
      // User already registered w/ pingable
      await sendFriendRequest(userId, contactList[contactIndex].id);
      setState(() {
        contactList[contactIndex].relationshipStatus = 0;
      });
      print("$firstName $lastName $phoneNumber -> Sending friend request");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Add a Friend'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 5.0, left: 5.0),
                  child: RaisedButton(
                      child: Text("From Pingable"),
                      onPressed: () async {
                        await displayScreen("database");
                      }),
                ),
                Container(
                  margin: EdgeInsets.only(right: 5.0, left: 5.0),
                  child: RaisedButton(
                      child: Text("From Contacts"),
                      onPressed: () async {
                        await displayScreen("contacts");
                      }),
                ),
              ],
            ),
            // This is aids but works -> Two ternary expressions
            // Switch on 'currentScreen'
            //    if "contacts" switch on 'loadingContacts'
            //        if 'loadingContacts' is true
            //            display AddFriendFromContacts
            //        else
            //            display Text("Loading contacts
            //    else display AddFriendSearchDatabase
            currentScreen == "contacts"
                ? (loadingContacts
                ? Text("Loading contacts...")
                : AddFriendFromContacts(
                callback: addFriend, contactList: contactList))
                : displayResults // TODO: Extract this logic and the variables above to another class
                ? Text("Results")
                : AddFriendSearchDatabase(callback: searchForFriends)
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme
              .of(context)
              .primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/api/friends.dart';
import 'package:pingable/components/stateless/addFriendFromContacts.dart';
import 'package:pingable/components/stateless/addFriendSearch.dart';
import 'package:pingable/models/friend.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFriendDialog extends StatefulWidget {
  AddFriendDialog();

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}




class _AddFriendDialogState extends State<AddFriendDialog> {
  bool loadingContacts = true;
  bool displayResults = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  String currentScreen;

  List<Friend> contactList;
  List<Friend> friendsFound;

  searchForFriendsAndUpdate(String firstName, String lastName) async {
    List<Friend> _friendsFound;
    _friendsFound = await searchForFriendsAndUpdate(firstName, lastName);

    setState(() {
      friendsFound = _friendsFound;
      displayResults = true;
    });
  }

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
        contactList = [];
        List<String> phoneNumbers = [];
        for (var entry in phoneContactList) {
          int id;
          String firstName = entry.givenName;
          String lastName = entry.familyName;
          String phoneNumber = entry.phones.toList()[0].value;
          int relationshipStatus = 0;


          contactList.add(
            new Friend(
                id, firstName, lastName, phoneNumber, relationshipStatus, null),
          );
          phoneNumbers.add(phoneNumber);
        }

        // Get data about friends from Pingable API
        var prefs = await SharedPreferences.getInstance();
        int userId = prefs.getInt('userId') ?? null;
        var result = lookupByPhoneNumbers(phoneNumbers, userId);

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

  addFriend(int id, String firstName, String lastName, String phoneNumber) {
    print("$firstName $lastName $phoneNumber -> WORKING");
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
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

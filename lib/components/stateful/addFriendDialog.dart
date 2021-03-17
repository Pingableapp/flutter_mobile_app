import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pingable/api/friendRequests.dart' as friendRequestsAPI;
import 'package:pingable/api/friends.dart' as friends;
import 'package:pingable/components/stateless/addFriendFromContacts.dart';
import 'package:pingable/components/stateless/addFriendSearch.dart';
import 'package:pingable/components/stateless/friendRequestList.dart';
import 'package:pingable/models/friend.dart';
import 'package:pingable/models/friendRequest.dart';
import 'package:pingable/models/user.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;
import 'package:pingable/use_cases/friendRequests.dart'
    as friendRequestsUseCase;
import 'package:pingable/use_cases/users.dart' as usersUseCase;

class AddFriendDialog extends StatefulWidget {
  AddFriendDialog();

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

extension E on String {
  String lastChars(int n) => substring(length - n);
}

List<Friend> removeFriendByPhoneNumber(
  List<Friend> friendList,
  String phoneNumber,
) {
  List<Friend> updatedFriendList = [];
  for (int i = 0; i < friendList.length; ++i) {
    Friend currFriend = friendList[i];
    String currFriendNumber =
        currFriend.phoneNumber.replaceAll(RegExp('[^0-9]'), '').lastChars(10);
    String phoneNumberToRemove =
        phoneNumber.replaceAll(RegExp('[^0-9]'), '').lastChars(10);
    if (currFriendNumber != phoneNumberToRemove) {
      updatedFriendList.add(currFriend);
    }
  }
  return updatedFriendList;
}

List<Friend> mergeFriendLists(List<Friend> listOne, List<Friend> listTwo) {
  // Given two lists of friends, combine them. On conflicts, use listOne's entry
  Map listTwoNumbersMap = {};
  for (int i = 0; i < listTwo.length; ++i) {
    Friend listTwoFriend = listTwo[i];
    String listTwoFriendNumber =
        listTwoFriend.phoneNumber.replaceAll(RegExp('[^0-9]'), '');
    if (listTwoFriendNumber.length >= 10) {
      listTwoNumbersMap[listTwoFriendNumber.lastChars(10)] = listTwoFriend;
    }
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

  // Add the remaining listTwo friends
  listTwoNumbersMap.forEach((key, value) => combinedFriends.add(value));
  return combinedFriends;
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  Timer timer;

  bool loadingContacts = true;
  bool displayResults = false;
  bool loadingFriendRequests = true;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  int numFriendRequests;

  TextEditingController searchTextController = TextEditingController()
    ..text = "";
  String currentScreen = "friendRequests";

  List<Friend> contactList;
  List<Friend> filteredContactList;
  List<FriendRequest> friendRequestList;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => refresh());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    timer.cancel();
    super.dispose();
  }

  void refresh() async {
    print("add_friend_dialog_refresh");
    List<FriendRequest> friendRequests = FriendRequest.sortListFirstLast(
        await friendRequestsUseCase.getFriendRequests());
    if (mounted) {
      setState(() {
        numFriendRequests = friendRequests.length;
        loadingFriendRequests = false;
        friendRequestList = friendRequests;
      });
    }
  }

  Future displayScreen(String screen) async {
    String _currentScreen = screen;
    int userId = await usersUseCase.getLoggedInUserId();

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
          try {
            int id;
            String firstName = entry.givenName;
            String lastName = entry.familyName;
            String phoneNumber = entry.phones.toList()[0].value;
            int relationshipStatus = 0;

            updatedContactList.add(
              new Friend(id, firstName, lastName, phoneNumber,
                  relationshipStatus, null),
            );
            phoneNumbers.add(phoneNumber);
          } catch (e) {
            // TODO: add in logging later so we can determine the weird phone formats we see
            print("Failed to load contact");
          }
        }

        // Get data about friends from Pingable API
        var existingContactListFriends =
            await friends.lookupByPhoneNumbers(phoneNumbers, userId);
        updatedContactList =
            mergeFriendLists(existingContactListFriends, updatedContactList);
        String phoneNumber = "1-512-399-4356";
        updatedContactList =
            removeFriendByPhoneNumber(updatedContactList, phoneNumber);
        updatedContactList = User.sortUserListFirstLast(updatedContactList);

        setState(() {
          loadingContacts = false;
          contactList = updatedContactList;
          filteredContactList = updatedContactList;
        });
      } else {
        // Failed to verify access to phone contacts
        _currentScreen = "needContactAccess";
      }
    } else if (currentScreen == "friendRequests") {
      List<FriendRequest> friendRequests = FriendRequest.sortListFirstLast(
          await friendRequestsUseCase.getFriendRequests());
      setState(() {
        numFriendRequests = friendRequests.length;
        loadingFriendRequests = false;
        friendRequestList = friendRequests;
      });
    } else if (currentScreen == "database") {
      // Do nothing for now
    }

    setState(() {
      currentScreen = _currentScreen;
    });
  }

  acceptFriendRequest(int sendingUserId, String receivingPhoneNumber) async {
    // Find the user we are looking for
    List<FriendRequest> updatedFriendRequests = friendRequestList;
    int friendRequestIndex;

    for (int i = 0; i < updatedFriendRequests.length; ++i) {
      FriendRequest currFriendRequest = updatedFriendRequests[i];
      if (currFriendRequest.sendingUserId == sendingUserId &&
          currFriendRequest.receivingPhoneNumber == receivingPhoneNumber) {
        friendRequestIndex = i;
        break;
      }
    }
    int userId = await usersUseCase.getLoggedInUserId();
    await friendRequestsAPI.acceptFriendRequest(sendingUserId, userId);
    updatedFriendRequests.removeAt(friendRequestIndex);
    setState(() {
      friendRequestList = updatedFriendRequests;
      numFriendRequests = updatedFriendRequests.length;
    });
  }

  addFriend(
      int id, String firstName, String lastName, String phoneNumber) async {
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

    int userId = await usersUseCase.getLoggedInUserId();

    if (id == null) {
      // User doesn't exist yet - send invite
      await friends.sendInviteToPingable(
          userId, contactList[contactIndex].phoneNumber);
      setState(() {
        contactList[contactIndex].relationshipStatus = 0;
        contactList[contactIndex].id = -1;
      });
      print("$firstName $lastName $phoneNumber -> Sending pingable invite");
    } else {
      // User already registered w/ pingable
      await friends.sendFriendRequest(userId, contactList[contactIndex].id);
      setState(() {
        contactList[contactIndex].relationshipStatus = 0;
      });
      print("$firstName $lastName $phoneNumber -> Sending friend request");
    }
  }

  void updateSearchResults(String updatedText) {
    if (updatedText == null || updatedText == "") {
      setState(() {
        filteredContactList = contactList;
      });
    } else {
      List<Friend> tempContactList = [];
      for (int i = 0; i < contactList.length; ++i) {
        if (contactList[i]
            .fullName
            .toLowerCase()
            .contains(updatedText.toLowerCase())) {
          tempContactList.add(contactList[i]);
        }
      }
      setState(() {
        filteredContactList = tempContactList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Add a Friend'),
      content: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * .9,
        child: SingleChildScrollView(
          child: Column(
            children: [
              numFriendRequests != null && numFriendRequests > 0
                  ? Container(
                      margin: EdgeInsets.only(right: 5.0, left: 5.0),
                      child: ElevatedButton(
                        child: Text("Friend Requests ($numFriendRequests)"),
                        onPressed: () async {
                          clickTrackingUseCase.recordClickTrackingEvent(
                              "friend_requests", "click", "");
                          await displayScreen("friendRequests");
                        },
                      ),
                    )
                  : SizedBox.shrink(),
              // SizedBox.shrink() is equivalent to null
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 5.0, left: 5.0),
                    child: ElevatedButton(
                      child: Text("From Contacts"),
                      onPressed: () async {
                        clickTrackingUseCase.recordClickTrackingEvent(
                            "from_contacts", "click", "");
                        await displayScreen("contacts");
                      },
                    ),
                  ),
                ],
              ),
              getCurrentScreen()
            ],
          ),
        ),
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            primary: Theme.of(context).primaryColor,
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case "contacts":
        return loadingContacts
            ? Text("Loading contacts...")
            : AddFriendFromContacts(
                searchTextController: searchTextController,
                callbackContactClick: addFriend,
                callbackSearchTextChange: updateSearchResults,
                contactList: filteredContactList,
              );
      case "database":
        return displayResults
            ? Text("Results")
            : AddFriendSearchDatabase(
                callback: friends.searchForFriends,
              );
      case "friendRequests":
        return loadingFriendRequests
            ? Text("Loading friend requests...")
            : FriendRequestList(
                friendRequestList: friendRequestList,
                callback: acceptFriendRequest,
              );
      default:
        return Text("Error.");
    }
  }
}

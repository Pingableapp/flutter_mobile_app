import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/api/friends.dart' as friendsAPI;
import 'package:pingable/api/pingableStatus.dart' as pingableStatusAPI;
import 'package:pingable/components/stateless/appBarActions.dart';
import 'package:pingable/components/stateless/friends.dart';
import 'package:pingable/components/stateless/pingableCircle.dart';
import 'package:pingable/models/friend.dart';
import 'package:pingable/models/status.dart';
import 'package:pingable/models/user.dart';
import 'package:pingable/shared/sharedPref.dart';
import 'package:pingable/use_cases/friendRequests.dart' as friendRequestsUseCase;
import 'package:pingable/use_cases/screenSize.dart' as screenSizeUseCase;
import 'package:pingable/use_cases/users.dart' as usersUseCase;

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer timer;
  int userId;
  String authToken;
  User user;
  bool currentlyPingable = false;
  List<Friend> listOfFriends = [];
  int friendRequests;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => refresh());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenSizeUseCase.setScreenWidth(MediaQuery.of(context).size.width.toInt());
      screenSizeUseCase.setScreenHeight(MediaQuery.of(context).size.height.toInt());
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    timer.cancel();
    super.dispose();
  }

  void refresh() async {
    print("home_refresh");
    await fetchPingableStatuses();
    List<Friend> _listOfFriends = await friendsAPI.getFriendsList(userId);
    int updatedFriendRequests = await friendRequestsUseCase.getFriendRequestsCount();

    setState(() {
      listOfFriends = _listOfFriends;
      isLoading = false;
      friendRequests = updatedFriendRequests;
    });
  }

  void fetchPingableStatuses() async {
    // 39 is coming from here
    List<Status> statusList = await pingableStatusAPI.getPingableAllStatus(userId);

    bool updatedCurrentlyPingable = false;
    for (var i = 0; i < statusList.length; i++) {
      if (statusList[i].type == "all" && statusList[i].status == 1) {
        updatedCurrentlyPingable = true;
      }
    }

    setState(() {
      currentlyPingable = updatedCurrentlyPingable;
    });
  }

  void flipCurrentlyPingable() async {
    // Loop through statuses to determine current "all" statusId
    List<Status> statuses = await pingableStatusAPI.getPingableAllStatus(userId);
    int allStatusID = -1;
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i].type == "all") {
        allStatusID = statuses[i].statusId;
      }
    }

    if (currentlyPingable) {
      // Set to pingable to false
      await pingableStatusAPI.updatePingableStatus(allStatusID, 0);
      setState(() {
        currentlyPingable = false;
      });
    } else {
      // Set to pingable to true
      await pingableStatusAPI.updatePingableStatus(allStatusID, 1);
      setState(() {
        currentlyPingable = true;
      });
    }
  }

  void loadInitialValues() async {
    userId = await usersUseCase.getLoggedInUserId();
    authToken = await usersUseCase.getAuthToken();
    SharedPref sharedPref = SharedPref();
    user = User.fromJson(await sharedPref.read("user"));
    friendRequests = await friendRequestsUseCase.getFriendRequestsCount();
  }

  _HomeState() {
    loadInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: isLoading ? Text("Pingable") : Text('Pingable - ${user.firstName} ${user.lastName}'),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AppBarActions(),
                      );
                    },
                    child: Icon(Icons.more_vert),
                  )),
            ],
          ),
          body: isLoading
              ? Text("Loading...")
              : Column(
                  children: [
                    Friends(
                      listOfFriends: listOfFriends,
                      friendRequests: friendRequests,
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Center(child: PingableCircle(currentlyPingable, flipCurrentlyPingable)))
                  ],
                ),
        ),
        onWillPop: () async => false);
  }
}

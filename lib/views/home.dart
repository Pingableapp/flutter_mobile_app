import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/api/friends.dart' as friendsAPI;
import 'package:pingable/api/pingableStatus.dart' as pingableStatusAPI;
import 'package:pingable/components/stateless/appBarActions.dart';
import 'package:pingable/components/stateless/friends.dart';
import 'package:pingable/components/stateless/hourMinuteCountdown.dart';
import 'package:pingable/components/stateless/pingableCircle.dart';
import 'package:pingable/components/stateless/pingableDurationPicker.dart';
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
  // Loading & Setup
  bool isLoading = true;
  Timer timer;

  // User/Session info
  User user;
  int userId;
  String authToken;
  List<Friend> listOfFriends = [];
  int friendRequests;

  // State
  bool pingableTimerActive = false;
  Duration pingableDuration = Duration(hours: 1);

  // TO remove
  bool currentlyPingable = false;

  @override
  void initState() {
    super.initState();
    int refreshDelay = 1500;
    timer = Timer.periodic(Duration(milliseconds: refreshDelay), (Timer t) => refresh());
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

    if (mounted) {
      setState(() {
        listOfFriends = _listOfFriends;
        isLoading = false;
        friendRequests = updatedFriendRequests;
      });
    }
  }

  void fetchPingableStatuses() async {
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

  void updatePingableDuration(Duration duration) {
    setState(() {
      pingableDuration = duration;
    });
  }

  void startTimer() async {
    // Loop through statuses to determine current "all" statusId
    List<Status> statuses = await pingableStatusAPI.getPingableAllStatus(userId);
    int allStatusID = -1;
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i].type == "all") {
        allStatusID = statuses[i].statusId;
      }
    }
    // TODO: make api call here to start timer and update duration
    await pingableStatusAPI.updatePingableStatus(allStatusID, 1);
    setState(() {
      currentlyPingable = true;
      pingableTimerActive = true;
    });
  }

  void changeToNotPingable() async {
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
        pingableTimerActive = false;
      });
    }
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
                ),
              ),
            ],
          ),
          body: isLoading
              ? Container(
                  child: Center(
                    child: Text("Pinging our servers..."),
                  ),
                )
              : Column(
                  children: [
                    Friends(
                      listOfFriends: listOfFriends,
                      friendRequests: friendRequests,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Center(
                        child: PingableCircle(currentlyPingable, changeToNotPingable),
                      ),
                    ),
                    pingableTimerActive
                        ? Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 30.0, bottom: 5.0),
                                child: Text(
                                  "Time remaining",
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              Container(
                                width: 350,
                                child: Center(
                                  child: HourMinuteCountdown(pingableDuration),
                                ),
                              ),
                            ],
                          ) // SizedBox.shrink() is equivalent to null
                        : Container(
                            width: 350,
                            child: Center(
                              child: PingableDurationPicker(pingableDuration, updatePingableDuration, startTimer),
                            ),
                          )
                  ],
                ),
        ),
        onWillPop: () async => false);
  }
}

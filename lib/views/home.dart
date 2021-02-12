import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/api/friends.dart';
import 'package:pingable/api/pingableStatus.dart';
import 'package:pingable/components/stateless/appBarActions.dart';
import 'package:pingable/components/stateless/friends.dart';
import 'package:pingable/components/stateless/pingableCircle.dart';
import 'package:pingable/models/friend.dart';
import 'package:pingable/models/status.dart';
import 'package:pingable/models/user.dart';
import 'package:pingable/shared/sharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchPingableStatuses();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) => refresh());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    timer.cancel();
    super.dispose();
  }

  void refresh() async {
    await fetchPingableStatuses();
    List<Friend> _listOfFriends = await getFriendsList(userId);

    setState(() {
      listOfFriends = _listOfFriends;
      isLoading = false;
    });
  }

  void fetchPingableStatuses() async {
    // 39 is coming from here
    List<Status> statusList = await getPingableAllStatus(userId);

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
    List<Status> statuses = await getPingableAllStatus(userId);
    int allStatusID = -1;
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i].type == "all") {
        allStatusID = statuses[i].statusId;
      }
    }

    if (currentlyPingable) {
      // Set to pingable to false
      await updatePingableStatus(allStatusID, 0);
      setState(() {
        currentlyPingable = false;
      });
    } else {
      // Set to pingable to true
      await updatePingableStatus(allStatusID, 1);
      setState(() {
        currentlyPingable = true;
      });
    }
  }

  void loadInitialValues() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? null;
    authToken = prefs.getString('authToken') ?? null;
    SharedPref sharedPref = SharedPref();
    user = User.fromJson(await sharedPref.read("user"));
  }

  _HomeState() {
    loadInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: isLoading
                ? Text("Pingable")
                : Text('Pingable - ${user.firstName} ${user.lastName}'),
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
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Center(
                            child: PingableCircle(
                                currentlyPingable, flipCurrentlyPingable)))
                  ],
                ),
        ),
        onWillPop: () async => false);
  }
}

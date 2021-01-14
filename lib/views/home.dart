import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingable/components/stateful/friends.dart';
import 'package:pingable/components/stateless/pingableCircle.dart';
import 'package:pingable/configuration/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pingable/components/stateless/appBarActions.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer timer;
  int userId;
  String authToken;
  bool currentlyPingable = false;

  @override
  void initState() {
    super.initState();
    // fetchPingableStatuses();
    timer = Timer.periodic(
        Duration(seconds: 2), (Timer t) => fetchPingableStatuses());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    timer.cancel();
    super.dispose();
  }

  Future<bool> getPingableAllStatus(int userId) async {
    // Check to see if verification code is valid & retrieve auth token
    var getUrl = '$apiEndpoint/users/$userId/statuses';
    http.Response resGet = await http.get(getUrl);

    // Ensure proper status code
    if (resGet.statusCode != 200) {
      return false;
    }

    var statuses = jsonDecode(resGet.body)["results"];
    for (var i = 0; i < statuses.length; i++) {
      if (statuses[i]["type"] == "all") {
        // status == 1 means pingable
        return statuses[i]["status"] == 1;
      }
    }

    return false;
  }

  Future<bool> updatePingableStatus(int statusID, int statusCode) async {
    // Check to see if verification code is valid & retrieve auth token
    var getUrl = '$apiEndpoint/statuses/$statusID';
    String data = '{"status":"${statusCode.toString()}"}';
    http.Response resPut = await http.put(getUrl, body: data);

    // Ensure proper status code
    if (resPut.statusCode != 200) {
      return false;
    }

    return true;
  }

  void fetchPingableStatuses() async {
    bool updatedCurrentlyPingable = await getPingableAllStatus(userId);

    setState(() {
      currentlyPingable = updatedCurrentlyPingable;
    });
  }

  void flipCurrentlyPingable() async {
    int statusID = 2;
    if (currentlyPingable) {
      // Set to pingable to false
      await updatePingableStatus(statusID, 0);
      setState(() {
        currentlyPingable = false;
      });
    } else {
      // Set to pingable to true
      await updatePingableStatus(statusID, 1);
      setState(() {
        currentlyPingable = true;
      });
    }
  }

  void loadInitialValues() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? null;
    authToken = prefs.getString('authToken') ?? null;
  }

  _HomeState() {
    loadInitialValues();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pingable'),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            buildActionsPopupDialog(context),
                      );
                    },
                    child: Icon(Icons.more_vert),
                  )),
            ],
          ),
          body: Column(
            children: [
              Friends(userId),
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

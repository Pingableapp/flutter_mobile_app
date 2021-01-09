import 'dart:async';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingable/components/stateful/friends.dart';
import 'package:pingable/components/stateless/pingableCircle.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final String authToken;
  final int userId;

  const Home(this.userId, this.authToken);

  @override
  _HomeState createState() => _HomeState(this.userId, this.authToken);
}

class _HomeState extends State<Home> {
  Timer timer;
  int userId;
  String authToken;
  bool currentlyPingable = false;

  @override
  void initState() {
    super.initState();
    fetchPingableStatuses();
    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => fetchPingableStatuses());
  }

  Future<bool> getPingableAllStatus(int userId) async {
    // Check to see if verification code is valid & retrieve auth token
    var getUrl = 'http://10.0.2.2/api/v1/users/$userId/statuses';
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

  void fetchPingableStatuses() async {
    bool updatedCurrentlyPingable = await getPingableAllStatus(userId);

    setState(() {
      currentlyPingable = updatedCurrentlyPingable;
    });
  }

  void flipCurrentlyPingable() {
    if (currentlyPingable) {
      setState(() {
        currentlyPingable = false;
      });
    } else {
      setState(() {
        currentlyPingable = true;
      //  TODO: START FROM HERE.... YOU NEED TO CREATE a PUT call for updating user status
      });
    }
  }

  _HomeState(int _userId, String _authToken) {
    userId = _userId;
    authToken = _authToken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pingable')),
      body: Column(
        children: [
          Friends(userId),
          Container(
              margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Center(
                  child:
                      PingableCircle(currentlyPingable, flipCurrentlyPingable)))
        ],
      ),
    );
  }
}

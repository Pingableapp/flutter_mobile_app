import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/models/friend.dart';
import 'package:url_launcher/url_launcher.dart';

class FriendInfo extends StatelessWidget {
  final Friend friend;

  FriendInfo({this.friend});

  String isAvailable(bool available) {
    if (available) {
      return "Yes";
    } else {
      return "No";
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Contact ${friend.firstName} ${friend.lastName}'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Currently Pingable: ${isAvailable(friend.active)}"),
          Text("Phone number: ${friend.phoneNumber}"),
          RaisedButton(
            onPressed: friend.active
                ? () => _makePhoneCall('tel://${friend.phoneNumber}')
                : null,
            child: const Text('Make phone call'),
          ),
        ],
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
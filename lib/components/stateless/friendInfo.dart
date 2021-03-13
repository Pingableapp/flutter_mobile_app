import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/models/friend.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;
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
          ElevatedButton(
            onPressed: friend.active
                ? () {
                    clickTrackingUseCase.recordClickTrackingEvent(
                        "call_friend", "click", "");
                    _makePhoneCall('tel://${friend.phoneNumber}');
                  }
                : null,
            child: const Text('Make phone call'),
          ),
        ],
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
}

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;


typedef void StringCallback(int sendingUserId, String receivingPhoneNumber);

class FriendRequestListEntry extends StatelessWidget {
  final int sendingUserId;
  final String sendingFirstName;
  final String sendingLastName;
  final String receivingPhoneNumber;
  final String expirationTimestamp;
  final StringCallback callback;

  FriendRequestListEntry({
    this.sendingUserId,
    this.sendingFirstName,
    this.sendingLastName,
    this.receivingPhoneNumber,
    this.expirationTimestamp,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("${StringUtils.capitalize(sendingFirstName)} ${StringUtils.capitalize(sendingLastName)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  clickTrackingUseCase.recordClickTrackingEvent("accept_friend_request", "click", "");
                  callback(sendingUserId, receivingPhoneNumber);
                },
                child: Text(
                  "Accept friend request",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

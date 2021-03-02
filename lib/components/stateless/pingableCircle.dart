import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;

class PingableCircle extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;

  PingableCircle(this.active, this.onPressed);

  String getButtonText(bool active) {
    if (active) {
      return "You are Pingable";
    } else {
      return "You are not Pingable";
    }
  }

  Color getPrimaryColor(bool active) {
    if (active) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Color getSplashColor(bool active) {
    if (active) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        height: 125,
        child: RaisedButton(
            color: getPrimaryColor(active),
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.black)),
            onPressed: () {
              clickTrackingUseCase.recordClickTrackingEvent("update_pingable_status", "click", "active: $active");
              onPressed();
            },
            child: Align(
              child: Text(getButtonText(active)),
            )));
  }
}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef void DurationCallback(Duration duration);

class PingableDurationPicker extends StatelessWidget {
  final Duration startingDuration;
  final DurationCallback onChangeDuration;
  final VoidCallback onStartTimer;

  PingableDurationPicker(this.startingDuration, this.onChangeDuration, this.onStartTimer);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30.0, bottom: 5.0),
            child: Center(
              child: Text(
                'You are Pingable for',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          Container(
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: startingDuration,
              onTimerDurationChanged: (Duration duration) {
                onChangeDuration(duration);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 50.0, right: 50.0),
            child: ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                // padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              onPressed: onStartTimer,
              child: Align(
                child: Text('Start timer!'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

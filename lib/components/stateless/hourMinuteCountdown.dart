import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HourMinuteCountdown extends StatelessWidget {
  final Duration durationRemaining;

  HourMinuteCountdown(this.durationRemaining);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
            durationRemaining.toString().split(':')[0] + " hr " + durationRemaining.toString().split(':')[1] + " min",
            style: TextStyle(fontSize: 50)),
      ),
    );
  }
}

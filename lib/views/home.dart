import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: RaisedButton(
          child: Text(
            'Go back to first screen',
            style: TextStyle(fontSize: 24),
          ),
          // onPressed: () {
          //   _goBackToFirstScreen(context);
          // },
        ),
      ),
    );
  }
}

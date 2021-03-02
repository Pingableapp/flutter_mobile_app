import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Update extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Application')),
      body: Center(
        child: Container(
          width: 200,
          height: 125,
          child: Text("Please update this application!"),
        ),
      ),
    );
  }
}

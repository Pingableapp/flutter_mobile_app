import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApiError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Error'),
      ),
      body: Center(
        child: Container(
          width: 200,
          height: 125,
          child: Text("Please contact Blake DeBenon @ 281-703-4575."),
        ),
      ),
    );
  }
}

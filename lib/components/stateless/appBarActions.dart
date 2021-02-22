import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Actions'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setInt('userId', null);
              prefs.setString('authToken', null);
              Navigator.pushNamed(context, '/accounts');
            },
            child: const Text('Logout'),
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

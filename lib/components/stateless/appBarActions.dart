import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;
import 'package:pingable/use_cases/users.dart' as usersUseCase;


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
              clickTrackingUseCase.recordClickTrackingEvent("logout", "click", "");
              usersUseCase.resetLoggedInUserID();
              usersUseCase.resetAuthToken();
              Navigator.pushNamed(context, '/accounts');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            clickTrackingUseCase.recordClickTrackingEvent("close_app_bar", "click", "");
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

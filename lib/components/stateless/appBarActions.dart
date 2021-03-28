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
          ElevatedButton(
            onPressed: () async {
              clickTrackingUseCase.recordClickTrackingEvent("logout", "click", "");
              usersUseCase.resetLoggedInUserID();
              usersUseCase.resetAuthToken();
              Navigator.pushNamed(context, '/accounts');
              // TODO: Delete timers for fetching updates on logout
              // TODO: at the moment the timer exists after logout
              // TODO: applies to getting relationships and statuses
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            clickTrackingUseCase.recordClickTrackingEvent("close_app_bar", "click", "");
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

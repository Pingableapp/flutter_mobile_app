
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pingable/views/createAccount.dart';
import 'package:pingable/views/login.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Accounts> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          appBar: AppBar(title: Text('Accounts')),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Row(
                  children: [
                    Spacer(),
                    Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: RaisedButton(
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            _navigateToLogin(context);
                          },
                        )),
                    Container(
                        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: RaisedButton(
                          child: Text(
                            'Create Account',
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            _navigateToCreateAccount(context);
                          },
                        )),
                    Spacer()
                  ],
                )
              ])),
        ),
        onWillPop: () async => false);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
  }

  void _navigateToCreateAccount(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ));
  }
}

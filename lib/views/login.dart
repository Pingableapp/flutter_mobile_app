import 'package:flutter/material.dart';
import 'package:pingable/views/home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNumber = "";
  final phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 250,
          child: TextField(
            textAlign: TextAlign.center,
            controller: phoneNumberController,
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
            ),
          ),
        ),
        RaisedButton(
          child: Text(
            'Login',
            style: TextStyle(fontSize: 24),
          ),
          onPressed: () {
            phoneNumber = phoneNumberController.text;
            print(phoneNumber);
            // _navigateToSecondScreen(context);
          },
        )
      ])),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneNumberController.dispose();
    super.dispose();
  }

  void _navigateToSecondScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ));
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;
import 'package:pingable/views/verify.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNumber = "";
  int userId;
  final phoneNumberController = TextEditingController();

  String errorMessage = "";

  // TODO: Remove duplicate copy of this function in createAccount
  // Trigger Twillio to send user a verification code
  Future<int> requestPhoneVerificationCode(String phoneNumber) async {
    // Verify proper phone number format
    RegExp exp = new RegExp(r"^[0-9]{1,3}-[0-9]{3}-[0-9]{3}-[0-9]{4}$");
    phoneNumber = phoneNumber.replaceAll('\t', '').replaceAll(' ', '');
    bool matchFound = exp.hasMatch(phoneNumber);
    if (!matchFound) {
      setState(() {
        errorMessage = "Invalid phone format. Enter as X-XXX-XXX-XXXX";
      });
      return -1;
    }

    // First check to see if phone number already exists
    // TODO: Move API functionality to API library
    var getUrl = '$apiEndpoint/users?phone_number=$phoneNumber';
    http.Response resGet = await http.get(getUrl);
    var resultsGet = jsonDecode(resGet.body)["results"];
    if (resultsGet.length != 1) {
      setState(() {
        errorMessage = "Account does not exist for number $phoneNumber. Please create a new account.";
      });
      return -1;
    }

    // One result was found so we must request a code for the returned user ID
    userId = resultsGet[0]["id"];
    var putUrl = '$apiEndpoint/users/$userId/verification_codes';
    http.Response resPut = await http.put(putUrl);
    var resultsPut = jsonDecode(resPut.body);
    if (resultsPut != "success") {
      setState(() {
        errorMessage = "Error requesting new verification code.";
      });
      return -1;
    }

    setState(() {
      errorMessage = "";
    });
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 350,
                child: Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.red))),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 5.0, bottom: 15.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                ),
              ),
            ),
            Row(
              children: [
                Spacer(),
                Container(
                    margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: ElevatedButton(
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () async {
                        clickTrackingUseCase.recordClickTrackingEvent("login_submit", "click", "");
                        phoneNumber = phoneNumberController.text.replaceAll('\t', '').replaceAll(' ', '');
                        var result = await requestPhoneVerificationCode(phoneNumber);
                        if (result == 0) {
                          _navigateToVerify(context);
                        }
                      },
                    )),
                Container(
                    margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: ElevatedButton(
                      child: Text(
                        'Back',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () {
                        clickTrackingUseCase.recordClickTrackingEvent("login_back", "click", "");
                        Navigator.pop(context);
                      },
                    )),
                Spacer()
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneNumberController.dispose();
    super.dispose();
  }

  void _navigateToVerify(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Verify(phoneNumber, userId),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
  }
}

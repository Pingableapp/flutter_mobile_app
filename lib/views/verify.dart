import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pingable/configuration/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Verify extends StatefulWidget {
  final String phoneNumber;
  final int userId;

  const Verify(this.phoneNumber, this.userId);

  @override
  _VerifyState createState() => _VerifyState(phoneNumber, userId);
}

class _VerifyState extends State<Verify> {
  int userId;
  String phoneNumber;
  final verificationCodeController = TextEditingController();
  String errorMessage = "";

  _VerifyState(String _phoneNumber, int _userId) {
    phoneNumber = _phoneNumber;
    userId = _userId;
  }

  Future<String> getAuthToken(int userId, String verificationCode) async {
    // Check to see if verification code is valid & retrieve auth token
    var getUrl =
        '$apiEndpoint/users/$userId/auth_tokens?verification_code=$verificationCode';
    http.Response resGet = await http.get(getUrl);

    // Ensure proper status code
    if (resGet.statusCode != 200) {
      return "invalid_response_code";
    }

    var authToken = jsonDecode(resGet.body)["auth_token"];
    return authToken;
  }

  Future<String> validateVerificationCode(String verificationCode) async {
    // Verify proper verification code format
    RegExp exp = new RegExp(r"^[0-9]{6}$");
    bool matchFound = exp.hasMatch(verificationCode);
    if (!matchFound) {
      setState(() {
        errorMessage = "Invalid verification code format. Enter as XXXXXX";
      });
      return null;
    }

    // Check to see if verification code is valid & retrieve auth token
    var authToken = await getAuthToken(userId, verificationCode);
    if (authToken == "invalid_response_code") {
      // We have an invalid verification code
      setState(() {
        errorMessage = "Invalid verification code provided.";
      });
      return null;
    }

    // Attempt to generate a new auth token if first attempt failed
    if (authToken == null) {
      var putUrl = '$apiEndpoint/users/$userId/auth_tokens';
      http.Response resPut = await http.put(putUrl);
      var resultsPut = jsonDecode(resPut.body);
      if (resultsPut != "success") {
        setState(() {
          errorMessage = "Error updating auth_token.";
        });
        return null;
      }

      // Fail out if authToken is still null
      authToken = await getAuthToken(userId, verificationCode);
      if (authToken == null) {
        setState(() {
          errorMessage = "Could not verify the phone number.";
        });
        return null;
      }
    }

    // Success
    setState(() {
      errorMessage = "";
    });
    return authToken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Phone Number')),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 350,
            child: Text(
              "A verification code has been sent to $phoneNumber",
              textAlign: TextAlign.center,
            )),
        Container(
            width: 350,
            margin: const EdgeInsets.only(top: 15.0, bottom: 0),
            child: Text(errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red))),
        Container(
          width: 250,
          margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextField(
            textAlign: TextAlign.center,
            controller: verificationCodeController,
            decoration: InputDecoration(
              hintText: 'Enter verification code...',
            ),
          ),
        ),
        Container(
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: RaisedButton(
              child: Text(
                'Verify',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () async {
                // Attempt to obtain authToken
                String verificationCodeString = verificationCodeController.text;
                var authToken =
                    await validateVerificationCode(verificationCodeString);

                // Check for success
                if (authToken == null) {
                  return;
                }

                // Save values to local storage
                final prefs = await SharedPreferences.getInstance();
                prefs.setInt('userId', this.userId);
                prefs.setString('authToken', authToken);

                _navigateToHome(context, this.userId, authToken);
              },
            )),
      ])),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    verificationCodeController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext context, int userId, String authToken) {
    Navigator.pushNamed(context, '/home');
  }
}

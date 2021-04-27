import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pingable/configuration/api.dart';
import 'package:pingable/functions/strings.dart';
import 'package:pingable/use_cases/clickTracking.dart' as clickTrackingUseCase;
import 'package:pingable/views/verify.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String initialCountry = 'US';
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  String phoneNumber = "";
  String formattedPhoneNumber = "";
  int userId;
  final phoneNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  String errorMessage = "";

  Future<int> requestCreateNewAccount(String phoneNumber, String email, String firstName, String lastName) async {
    setState(() {
      errorMessage = "";
    });

    // Verify proper phone number format
    RegExp exp = new RegExp(r"^[0-9]{1,3}-[0-9]{3}-[0-9]{3}-[0-9]{4}$");
    phoneNumber = phoneNumber.replaceAll(' ', '').replaceAll('\t', '');
    bool matchFound = exp.hasMatch(phoneNumber);
    if (!matchFound) {
      setState(() {
        errorMessage = "Invalid phone format. Enter as XXXXXXXXXX";
      });
      return -1;
    }

    // Verify proper email format
    exp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    email = email.toLowerCase().replaceAll(' ', '').replaceAll('\t', '');
    matchFound = exp.hasMatch(email);
    if (!matchFound) {
      setState(() {
        errorMessage = "Invalid email address provided.";
      });
      return -1;
    }

    // Verify proper first name format
    exp = new RegExp(r"^[\w'\-,.][^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$");
    firstName = firstName.toLowerCase();
    matchFound = exp.hasMatch(firstName);
    if (!matchFound) {
      setState(() {
        errorMessage = "Please enter a valid first name.";
      });
      return -1;
    }

    // Verify proper last name format
    exp = new RegExp(r"^[\w'\-,.][^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$");
    lastName = lastName.toLowerCase();
    matchFound = exp.hasMatch(lastName);
    if (!matchFound) {
      setState(() {
        errorMessage = "Please enter a valid last name.";
      });
      return -1;
    }

    // One result was found so we must request a code for the returned user ID
    var postUrl = '$apiEndpoint/users';
    String data =
        '{"email": "$email", "first_name": "$firstName", "last_name": "$lastName","phone_number": "$phoneNumber"}';
    http.Response resPost = await http.post(postUrl, body: data);

    if (resPost.statusCode == 409) {
      setState(() {
        errorMessage = "Phone number or email are already taken! Please login or use another number.";
      });
      return -1;
    }

    if (resPost.statusCode == 400) {
      setState(() {
        errorMessage = "Failed to create new account.";
      });
      return -1;
    }

    setState(() {
      errorMessage = "";
    });
    return 0;
  }

  // TODO: Remove duplicate copy of this function in login
  // Trigger Twillio to send user a verification code
  Future<int> requestPhoneVerificationCode(String phoneNumber) async {
    // Verify proper phone number format
    RegExp exp = new RegExp(r"^[0-9]{1,3}-[0-9]{3}-[0-9]{3}-[0-9]{4}$");
    bool matchFound = exp.hasMatch(phoneNumber);
    if (!matchFound) {
      setState(() {
        errorMessage = "Invalid phone format. Enter as XXXXXXXXXX";
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
      String errorText;
      if (resultsPut["message"] == "Invalid phone number provided") {
        errorText = "Invalid number. Phone number must be active/real.";
      } else {
        errorText = "Error requesting new verification code.";
      }
      setState(() {
        errorMessage = errorText;
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
        title: Text('Create Account'),
      ),
      body: Center(
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0, bottom: 5.0),
              width: 350,
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 25, right: 25),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    phoneNumber = number.phoneNumber;
                  });
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                autoFocus: true,
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: number,
                textFieldController: phoneNumberController,
                formatInput: true,
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                hintText: 'Enter your phone number',
                countries: ["US"],
                spaceBetweenSelectorAndTextField: 0,
                maxLength: 10,
              ),
            ),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 25, right: 25),
              child: TextField(
                textAlign: TextAlign.left,
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                ),
              ),
            ),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 25, right: 25),
              child: TextField(
                textAlign: TextAlign.left,
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                ),
              ),
            ),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 5.0, bottom: 20.0, left: 25, right: 25),
              child: TextField(
                textAlign: TextAlign.left,
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
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
                      'Back',
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: () {
                      clickTrackingUseCase.recordClickTrackingEvent("create_account_back", "click", "");
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: ElevatedButton(
                      child: Text(
                        'Create',
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () async {
                        clickTrackingUseCase.recordClickTrackingEvent("create_account_submit", "click", "");
                        formattedPhoneNumber = formatPhoneNumber(phoneNumber);
                        String email = emailController.text.replaceAll('\t', '').replaceAll(' ', '');
                        String firstName = firstNameController.text;
                        String lastName = lastNameController.text;
                        var result = await requestCreateNewAccount(formattedPhoneNumber, email, firstName, lastName);
                        if (result == 0) {
                          int requestStatus = await requestPhoneVerificationCode(formattedPhoneNumber);
                          if (requestStatus != -1) {
                            _navigateToVerify(context);
                          }
                        }
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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _navigateToVerify(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Verify(formattedPhoneNumber, userId),
      ),
    );
  }
}

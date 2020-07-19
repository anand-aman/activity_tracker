import 'package:activitytrackerapp/screens/home_page.dart';
import 'package:activitytrackerapp/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:activitytrackerapp/constants.dart';
import 'package:activitytrackerapp/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  final _userNameInputController = TextEditingController();
  final _emailInputController = TextEditingController();
  final _pwdInputController = TextEditingController();
  final _confirmPwdInputController = TextEditingController();
  bool showSpinner = false;

  @override
  void dispose() {
    _userNameInputController.dispose();
    _emailInputController.dispose();
    _pwdInputController.dispose();
    _confirmPwdInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Color(0xFF222B45),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _userNameInputController,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Name',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: _emailInputController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Email',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: _pwdInputController,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: kTextFieldDecoration.copyWith(hintText: 'Password'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: _confirmPwdInputController,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: kTextFieldDecoration.copyWith(hintText: 'Confirm Password'),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                    buttonName: 'Register',
                    buttonColor: Colors.lightBlueAccent,
                    onPress: () async {
                      if (_pwdInputController.text != _confirmPwdInputController.text) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("The passwords do not match"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        );
                        return;
                      }

                      setState(() {
                        showSpinner = true;
                      });
                      _auth
                          .createUserWithEmailAndPassword(
                              email: _emailInputController.text, password: _pwdInputController.text)
                          .then((currentUser) {
                        Firestore.instance.collection('users').document(currentUser.user.uid).setData({
                          "uid": currentUser.user.uid,
                          "name": _userNameInputController.text,
                          "email": _emailInputController.text,
                          "active": false,
                        });
                      }).then(
                        (value) {
                          setState(() {
                            showSpinner = false;
                          });
                          Navigator.pushReplacementNamed(context, HomePage.id);
                        },
                      ).catchError((onError) {
                        setState(() {
                          showSpinner = false;
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text(onError.toString()),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      }).catchError((onError) {
                        setState(() {
                          showSpinner = false;
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text(onError.toString()),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('email', _emailInputController.text);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        FlatButton(
                          child: Text(
                            "Login here!",
                            style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 20,
                                fontFamily: 'Shadows',
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, LoginPage.id);
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

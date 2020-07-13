import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:activitytrackerapp/components/custom_cards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:activitytrackerapp/services/active_user_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:activitytrackerapp/services/loggedin_user.dart' as currentUser;

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String dropdownValue = 'Web';
  bool _isActive;
  bool _isLoaded = false;
  String _activeUserDocID;
  String _userName = "";

  Future<void> getUser() async {
    loggedInUser = await currentUser.getCurrentUser();
  }

  void getData() async {
    await getUser().then((value) {
      _firestore.collection('users').document(loggedInUser.uid).get().then((value) {
        _isActive = value.data['active'];
        _activeUserDocID = value.data['activeDocID'];
        _userName = value.data['name'];
      }).then((value) {
        setState(() {
          _isLoaded = true;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    _firebaseMessaging.getToken().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF222B45),
      appBar: AppBar(
        title: Text('Activity Tracker'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            splashColor: Colors.white30,
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('email');
            },
          )
        ],
        backgroundColor: Color(0xFF222B45),
      ),
      body: SafeArea(
        child: _isLoaded
            ? Column(
                children: <Widget>[
                  Expanded(
                    child: ContainerCard(
                      cardChild: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color(0x334AC2AB),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              'Active Users',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4AC2AB),
                                fontSize: 22.0,
                              ),
                            ),
                          ),
                          Container(
                            color: Color(0xFF2E3A59),
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            height: 2.0,
                          ), //HorizontalDivider
                          Expanded(
                            child: ActiveUserStream(),
                          ) //Will be changed to StreamBuilder
                        ],
                      ),
                    ),
                  ),
                  ContainerCard(
                    cardChild: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              _userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                          _isActive
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(left: 10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0x990676ED),
                                    ),
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      elevation: 15,
                                      value: dropdownValue,
                                      hint: Text(
                                        'Platform',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                      ),
                                      dropdownColor: Color(0xFF1A1F38),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      onChanged: (String value) {
                                        print(value);
                                        setState(() {
                                          dropdownValue = value;
                                        });
                                      },
                                      items: <String>['Web', 'Android', 'iOS']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RaisedButton(
                              color: _isActive ? Colors.redAccent : Color(0xFF0676ED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Text(
                                _isActive ? 'End' : 'Start',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              onPressed: _isActive
                                  ? () {
                                      _firestore.collection("active").document(_activeUserDocID).delete();
                                      _firestore
                                          .collection("users")
                                          .document(loggedInUser.uid)
                                          .updateData({"active": false});
                                      setState(() {
                                        _isActive = !_isActive;
                                      });
                                    }
                                  : () {
                                      print(loggedInUser.uid);
                                      _firestore.collection("active").add({
                                        "name": _userName,
                                        "platform": dropdownValue,
                                        "time": TimeOfDay.now().format(context).toString(),
                                      }).then((docRef) {
                                        _firestore.collection("users").document(loggedInUser.uid).updateData({
                                          "active": true,
                                          "activeDocID": docRef.documentID,
                                        });
                                        _activeUserDocID = docRef.documentID;
                                      });
                                      setState(() {
                                        _isActive = !_isActive;
                                      });
                                    },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

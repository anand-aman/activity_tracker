import 'package:activitytrackerapp/components/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'package:activitytrackerapp/services/loggedin_user.dart' as currentUser;

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

// ignore: camel_case_types
class ChitChat_Screen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChitChat_ScreenState createState() => _ChitChat_ScreenState();
}

// ignore: camel_case_types
class _ChitChat_ScreenState extends State<ChitChat_Screen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      loggedInUser = await currentUser.getCurrentUser();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat Arena'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              splashColor: Colors.white30,
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('email');
                Navigator.pushReplacementNamed(context, LoginPage.id);
              },
            )
          ],
          backgroundColor: Color(0xFF222B45),
        ),
        drawer: drawer1(
          go_to: HomePage.id,
          displayTxt: 'Home Page',
        ),
        body: SafeArea(
          child: Container(
            color: Color(0xFF222B45),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                MessagesStream(),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.amber, width: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: messageTextController,
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            messageText = value;
                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w100),
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            hintText: 'Type your message here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          messageTextController.clear();
                          _firestore.collection('chats').add({}).then((docRef) {
                            _firestore.collection('chats').document(docRef.documentID).setData({
                              'text': messageText,
                              'sender': currentUser.username,
                              'senderEmail': loggedInUser.email,
                              'msgDocID': docRef.documentID,
                              'time':
                                  Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch),
                            });
                          });
                        },
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chats').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final senderEmail = message.data['senderEmail'];
          final msgDocID = message.data['msgDocID'];
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: senderEmail == loggedInUser.email,
            documentID: msgDocID,
            senderEmail: senderEmail,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.senderEmail, this.text, this.isMe, this.documentID});

  final String sender;
  final String senderEmail;
  final String text;
  final bool isMe;
  final String documentID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              sender,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.cyan,
              ),
            ),
          ),
          GestureDetector(
            child: Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black54,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            onLongPress: () {
              if (loggedInUser.email == senderEmail) {
                _firestore.collection('chats').document(documentID).delete();
                print('Message Deleted.');
              }
            },
          ),
        ],
      ),
    );
  }
}

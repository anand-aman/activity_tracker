import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:activitytrackerapp/components/custom_cards.dart';

final _firestore = Firestore.instance;

class ActiveUserStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('active').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final activeUsers = snapshot.data.documents;
        List<ActiveUserCard> activeUserCards = [];
        for (var user in activeUsers) {
          final userName = user.data['name'];
          final userPlatform = user.data['platform'];
          final userStartTime = user.data['time'];

          final activeUserCard = ActiveUserCard(
            userName: userName,
            platform: userPlatform,
            startTime: userStartTime,
          );

          activeUserCards.add(activeUserCard);
        }
        return ListView(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: activeUserCards,
        );
      },
    );
  }
}

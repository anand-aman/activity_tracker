import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:activitytrackerapp/constants.dart';

class ContainerCard extends StatelessWidget {
  final Widget cardChild;

  ContainerCard({this.cardChild});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(15.0),
      color: Color(0xFF151A30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: cardChild,
      ),
    );
  }
}

class ActiveUserCard extends StatelessWidget {
  final String userName;
  final String platform;
  final String startTime;

  ActiveUserCard({this.userName, this.platform, this.startTime});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF2E3A59),
          ),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              userName,
              style: TextStyle(
                color: Colors.white,
//                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
            ),
            kVerticalDivider,
            Text(
              platform,
              style: TextStyle(color: Color(0xFF8F9BB3), fontWeight: FontWeight.w400, fontSize: 20.0),
            ),
            kVerticalDivider,
            Text(
              startTime,
              style: TextStyle(color: Color(0xFF8F9BB3), fontWeight: FontWeight.w400, fontSize: 20.0),
            )
          ],
        ),
      ),
    );
  }
}

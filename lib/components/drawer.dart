import 'package:activitytrackerapp/screens/chat_page.dart';
import 'package:flutter/material.dart';

class drawer1 extends StatelessWidget {
  drawer1({@required this.go_to,@required this.displayTxt});
  final String go_to;
  final String displayTxt;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                height: 100,
                width: double.infinity,
                image: AssetImage('asset1/sdd.jpg'),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                    leading: Icon(
                      Icons.message,
                      size: 30,
                    ),
                    title: Text(
                      displayTxt,
                      style: TextStyle(fontSize: 24),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, go_to);
                    }),
              )
            ],
          )
        ],
      ),
    );
  }
}

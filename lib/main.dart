import 'package:activitytrackerapp/screens/chat_page.dart';
import 'package:activitytrackerapp/screens/registeration_page.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:activitytrackerapp/screens/chat_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  runApp(MaterialApp(
    initialRoute: email == null ? LoginPage.id : HomePage.id,
    routes: {
      LoginPage.id: (context) => LoginPage(),
      RegistrationScreen.id: (context) => RegistrationScreen(),
      ChitChat_Screen.id: (context) => ChitChat_Screen(),
      HomePage.id: (context) => HomePage(),
    },
  ));
}

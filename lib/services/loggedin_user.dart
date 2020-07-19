import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser _loggedInUser;
final _auth = FirebaseAuth.instance;
String _username = "";

String get username {
  return _username;
}

void set(String name) {
  _username = name;
}

Future<FirebaseUser> getCurrentUser() async {
  try {
    if (_loggedInUser != null) return _loggedInUser;

    final user = await _auth.currentUser();
    if (user != null) {
      _loggedInUser = user;
      return _loggedInUser;
    }
  } catch (e) {
    print(e);
  }
  return null;
}

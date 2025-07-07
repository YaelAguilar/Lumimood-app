import 'package:flutter/material.dart';

class WelcomeViewModel extends ChangeNotifier {

  void onRegisterTapped(BuildContext context) {
    Navigator.of(context).pushNamed('/register');
  }

  void onLoginTapped(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/diary');
  }
}
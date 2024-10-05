import 'package:direction_guesser/pages/camera_test.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/register.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (context) => LoginPage());
    case '/register':
      return MaterialPageRoute(builder: (context) => RegisterPage());
    // case '/home':
      //return MaterialPageRoute(builder: (context) => HomePage());
    case '/camera':
      return MaterialPageRoute(builder: (context) => CameraTestPage());
    default:
      return MaterialPageRoute(builder: (context) => ErrorWidget(Exception('Default route reached!')));
  }
}
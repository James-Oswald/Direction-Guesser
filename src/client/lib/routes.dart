import 'package:direction_guesser/pages/guess.dart';
import 'package:direction_guesser/pages/home.dart';
import 'package:direction_guesser/pages/score.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/register.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (context) => LoginPage());
    case '/register':
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case '/home':
      return MaterialPageRoute(builder: (context) => HomePage());
    case '/guess':
      return MaterialPageRoute(builder: (context) => GuessPage());
    case '/score':
      return MaterialPageRoute(builder: (context) => ScorePage(city: settings.arguments.toString()));
    default:
      return MaterialPageRoute(
          builder: (context) =>
              ErrorWidget(Exception('Default route reached!')));
  }
}
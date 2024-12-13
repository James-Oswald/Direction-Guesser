import 'package:direction_guesser/pages/guess.dart';
import 'package:direction_guesser/pages/home.dart';
import 'package:direction_guesser/pages/profile.dart';
import 'package:direction_guesser/pages/results.dart';
import 'package:direction_guesser/pages/score.dart';
import 'package:direction_guesser/pages/settings.dart';
import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/register.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return _createRoute(LoginPage());
    case '/register':
      return _createRoute(RegisterPage());
    case '/home':
      return _createRoute(HomePage());
    case '/guess':
      return _createRoute(GuessPage());
    case '/score':
      return _createRoute(ScorePage(city: settings.arguments.toString()));
    case '/results':
      return _createRoute(ResultsPage());
    case '/profile':
      return _createRoute(ProfilePage());
    case '/settings':
      return _createRoute(SettingsPage());
    default:
      return _createRoute(LoginPage());
  }
}

Route _createRoute(Widget destination) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

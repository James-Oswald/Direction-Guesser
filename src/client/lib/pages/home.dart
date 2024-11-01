import 'package:direction_guesser/widgets/leaderboard_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _homePageState();
}

class _homePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFFFAF8FF)
                    : Color(0xFF121318),
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFF495D92)
                    : Color(0xFF151B2C)
              ]),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  LeaderboardCard(),
                  FilledButton(
                      onPressed: onPressedSinglePlayer,
                      child: Text("Single-Player")),
                  FilledButton(
                      onPressed: onPressedMutliPlayer,
                      child: Text("Multi-Player"))
                ]))));
  }

  // TODO:
  void onPressedSinglePlayer() {}

  // TODO:
  void onPressedMutliPlayer() {}
}

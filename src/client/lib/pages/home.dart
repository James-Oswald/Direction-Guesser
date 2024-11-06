import 'package:direction_guesser/widgets/currency_pill.dart';
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
            body: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 64),
                      CurrencyPill(funds: 15827),
                      SizedBox(height: 32),
                      Expanded(
                          child:
                              Column(mainAxisSize: MainAxisSize.max, children: [
                        LeaderboardCard(),
                        Spacer(),
                        FilledButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/guess');
                            },
                            child: Text("Single-Player")),
                        FilledButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/guess');
                            },
                            child: Text("Multi-Player")),
                        Spacer(),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FilledButton.tonal(
                                  onPressed: () => {}, // TODO: implement
                                  child: Icon(
                                    Icons.settings_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  )),
                              FilledButton.tonal(
                                  onPressed: () => {}, // TODO: implement
                                  child: Icon(
                                    Icons.store_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  )),
                              FilledButton.tonal(
                                  onPressed: () => {}, // TODO: implement
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  )),
                              FilledButton.tonal(
                                  onPressed: () => {}, // TODO: implement
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ))
                            ]),
                        SizedBox(height: 16)
                      ]))
                    ]))));
  }
}

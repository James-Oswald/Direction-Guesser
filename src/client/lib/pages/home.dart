import 'package:direction_guesser/widgets/leaderboard_card.dart';
import 'package:direction_guesser/widgets/points_pill.dart';
import 'package:flutter/material.dart';

import '../widgets/text_entry_pill.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController roomCodeController = TextEditingController();

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
                      PointsPill(points: 15827),
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
                            child: Text("Single Player Match")),
                        SizedBox(height: 12),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 64,
                          child: TextEntryPill(
                            controller: roomCodeController,
                            icon: Icon(
                              Icons.qr_code_2_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                            hintText: "room code",
                            obscured: false,
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                  onPressed: () {
                                    // TODO: create room
                                  },
                                  child: Text("Create Room")),
                              SizedBox(width: 16),
                              FilledButton(
                                  onPressed: () {
                                    // TODO: join room
                                  },
                                  child: Text("Join Room")),
                            ]),
                        Spacer(),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FilledButton.tonal(
                                  onPressed: () => {
                                        Navigator.pushNamed(
                                            context, '/settings')
                                      },
                                  child: Icon(
                                    Icons.settings_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  )),
                              FilledButton.tonal(
                                  onPressed: () => { Navigator.pushNamed(context, '/login')},
                                  // TODO: implement logout
                                  child: Icon(
                                    Icons.exit_to_app_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  )),
                              FilledButton.tonal(
                                  onPressed: () => {
                                        Navigator.pushNamed(context, '/profile')
                                      },
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

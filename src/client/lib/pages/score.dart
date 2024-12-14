import 'package:direction_guesser/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({required this.city}) : super();

  final String city;

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {

  String? score;
  String? deg_off;

  @override
  void initState() {
    super.initState();
    _getScore();
    setState(() {});
  }

  void _getScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getString('score');
      deg_off = prefs.getString('deg_off');
      scores['score${roundNumber}'] = {
        'city': widget.city,
        'score': score ?? '0'
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle mediumStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.titleLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        color: Theme.of(context).colorScheme.onSurface);

    return PopScope(
        canPop: false,
        child: Container(
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
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                  Spacer(),
                  Text(
                    "Your guess for",
                    style: mediumStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(widget.city,
                      // TODO: this should come from the backend
                      style: TextStyle(
                          fontStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.fontStyle,
                          fontSize: 32,
                          color: Theme.of(context).colorScheme.error)),
                  SizedBox(height: 16),
                  Text(
                    "was",
                    style: mediumStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(deg_off ?? "XX.XX° off",
                      style: TextStyle(
                          fontStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.fontStyle,
                          fontSize: 32,
                          color: Theme.of(context).colorScheme.error)),
                  Spacer(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(score ?? "0",
                            style: TextStyle(
                                fontStyle: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.fontStyle,
                                fontSize: 128,
                                color: Theme.of(context).colorScheme.tertiary)),
                        Text("points",
                            style: TextStyle(
                                fontStyle: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.fontStyle,
                                fontSize: 32,
                                color: Theme.of(context).colorScheme.tertiary))
                      ]),
                  SizedBox(height: 16),
                  FilledButton(
                      onPressed: () {
                        if (roundNumber >= 2) {
                          roundNumber = 0;
                          if (roomState.value == RoomState.owner || roomState.value == RoomState.joiner) {
                            Navigator.pushNamed(context, '/multiplayer-results');
                          } else {
                            Navigator.pushNamed(context, '/results');
                          }
                        } else {
                          roundNumber++;
                          Navigator.pushNamed(context, '/guess');
                        }
                      },
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      )),
                  Spacer()
                ])))));
  }
}

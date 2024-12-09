import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage() : super();

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleLargeStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.titleLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        color: Theme.of(context).colorScheme.onSurface);

    TextStyle displaySmallStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.displaySmall?.fontStyle,
        fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
        color: Theme.of(context).colorScheme.primary);

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
                    "Your results for this match:",
                    style: titleLargeStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "City 1: 100 points",
                    style: displaySmallStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "City 2: 65 points",
                    style: displaySmallStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "City 3: 92 points",
                    style: displaySmallStyle,
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
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

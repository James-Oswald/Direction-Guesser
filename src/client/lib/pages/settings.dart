import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) {
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
            body: Row(children: [
              SizedBox(width: 64),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 128),
                  SizedBox(
                      height: 280,
                      width: 280,
                      child: CircleAvatar(
                          foregroundImage: AssetImage("assets/logo.png"),
                          backgroundColor: Colors.transparent)),
                  SizedBox(height: 16),
                  Text("Direction Guesser",
                      style: TextStyle(
                          fontStyle:
                              Theme.of(context).textTheme.titleLarge?.fontStyle,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge?.fontSize,
                          color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  Text(
                      "Developers: \n\t\tArmin Karic\n\t\tIshtyaq Khan\n\t\tSharie Rhea\n\t\tRune Vannaken",
                      style: TextStyle(
                          fontStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.fontStyle,
                          fontSize:
                              Theme.of(context).textTheme.titleMedium?.fontSize,
                          color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.left),
                  Text("Sponsor: \n\t\tJames Oswald",
                      style: TextStyle(
                          fontStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.fontStyle,
                          fontSize:
                              Theme.of(context).textTheme.titleMedium?.fontSize,
                          color: Theme.of(context).colorScheme.primary),
                      textAlign: TextAlign.left),
                  Spacer(),
                  FilledButton.tonal(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      )),
                  SizedBox(height: 32)
                ],
              ),
            ]),
          ));
    }));
  }
}

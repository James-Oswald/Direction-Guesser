import 'package:direction_guesser/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;

  @override
  Widget build(BuildContext context) {
    if (themeNotifier.value == ThemeMode.dark) {
      darkMode = true;
    }
    else if (themeNotifier.value == ThemeMode.light) {
      darkMode = false;
    }
    TextStyle mediumStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.titleMedium?.fontStyle,
        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
        color: Theme.of(context).colorScheme.onSurface);
    TextStyle largeStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.titleMedium?.fontStyle,
        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
        color: Theme.of(context).colorScheme.onSurface);

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
                        style: largeStyle, textAlign: TextAlign.center),
                    SizedBox(height: 16),
                    Text(
                        "Developers: \n\t\tArmin Karic\n\t\tIshtyaq Khan\n\t\tSharie Rhea\n\t\tRune Vannaken",
                        style: mediumStyle,
                        textAlign: TextAlign.left),
                    Text("Sponsor: \n\t\tJames Oswald",
                        style: mediumStyle, textAlign: TextAlign.left),
                    Spacer(),
                    Row(children: [
                      Switch(
                          value: darkMode,
                          onChanged: (bool value) {
                            setState(() {
                              darkMode = value;
                              themeNotifier.value =
                                  darkMode ? ThemeMode.dark : ThemeMode.light;
                            });
                          }),
                      SizedBox(width: 8),
                      Text("Dark Mode", style: mediumStyle)
                    ]),
                    Spacer(),
                    Row(children: [
                      Switch(
                          value: soundEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              soundEnabled = value;
                            });
                          }),
                      SizedBox(width: 8),
                      Text(
                        "Sound Effects",
                        style: mediumStyle,
                      )
                    ]),
                    Spacer(),
                    FilledButton.tonal(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        )),
                    SizedBox(height: 32),
                  ]),
            ]),
          ));
    }));
  }
}

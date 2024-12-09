import 'package:camera/camera.dart';
import 'package:direction_guesser/controllers/game_services.dart';
import 'package:direction_guesser/controllers/user_services.dart';
import 'package:direction_guesser/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';

List<CameraDescription> cameras = [];
bool soundEnabled = true;
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // poll available cameras on startup to prepare for guess screen
  cameras = await availableCameras();
  runApp(MultiProvider(providers: [
    Provider(create: (_) {
      UsersServices();
      GameServices();
    })
  ], child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, mode, __) {
          return MaterialApp(
              theme: MaterialTheme(Theme.of(context).textTheme)
                  .theme(MaterialTheme.lightScheme()),
              darkTheme: MaterialTheme(Theme.of(context).textTheme)
                  .theme(MaterialTheme.darkScheme()),
              themeMode: mode,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: generateRoute,
              initialRoute: CheckSessionStatus() ? '/home' : '/login');
        });
  }
}

bool CheckSessionStatus() {
  // Check if the user is logged in
  // If the user is logged in, return true
  // If the user is not logged in, return false
  //TODO: Implement this function
  return false;
}

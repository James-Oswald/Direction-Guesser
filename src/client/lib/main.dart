import 'package:camera/camera.dart';
import 'package:direction_guesser/theme.dart';
import 'package:direction_guesser/controllers/usersServices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MultiProvider(
      providers: [Provider(create: (_) => usersServices())], child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: MaterialTheme(Theme.of(context).textTheme)
            .theme(MaterialTheme.lightScheme()),
        darkTheme: MaterialTheme(Theme.of(context).textTheme)
            .theme(MaterialTheme.darkScheme()),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: generateRoute,
        initialRoute: CheckSessionStatus() ? '/home' : '/guess');
  }
}

bool CheckSessionStatus() {
  // Check if the user is logged in
  // If the user is logged in, return true
  // If the user is not logged in, return false
  //TODO: Implement this function
  return false;
}

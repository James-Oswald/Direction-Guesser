import 'package:camera/camera.dart';
import 'package:direction_guesser/controllers/game_services.dart';
import 'package:direction_guesser/controllers/user_services.dart';
import 'package:direction_guesser/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';

List<CameraDescription> cameras = [];
bool soundEnabled = true;
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
int roundNumber = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // poll available cameras on startup to prepare for guess screen
  cameras = await availableCameras();
  runApp(MultiProvider(providers: [
    Provider<UsersServices>(create: (context) => UsersServices()),
    Provider<GameServices>(create: (context) => GameServices())
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
              theme: MaterialTheme(Theme
                  .of(context)
                  .textTheme)
                  .theme(MaterialTheme.lightScheme()),
              darkTheme: MaterialTheme(Theme
                  .of(context)
                  .textTheme)
                  .theme(MaterialTheme.darkScheme()),
              themeMode: mode,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: generateRoute,
              home: SplashScreen());
        });
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionStatus(); // Check session status asynchronously
  }

  Future<void> _checkSessionStatus() async {
    await Future.delayed(Duration(seconds: 1)); // Optional delay for better UX
    final prefs = await SharedPreferences.getInstance();
    var sessionId = prefs.getString('x-auth-token');

    if (sessionId != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme
                    .of(context)
                    .colorScheme
                    .primary),
          )), // Splash/loading screen
    );
  }
}

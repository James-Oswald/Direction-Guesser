import 'package:camera/camera.dart';
import 'package:direction_guesser/controllers/game_services.dart';
import 'package:direction_guesser/controllers/user_services.dart';
import 'package:direction_guesser/models/game.dart';
import 'package:direction_guesser/models/user.dart'; 
import 'package:direction_guesser/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';

// Global variables
// These are used to store the theme, cameras, sound settings, room state of lobby ui, user, and game objects
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
List<CameraDescription> cameras = [];
bool soundEnabled = true;
bool globeEnabled = true;
const String globeLight = 'assets/2k_earth-day.jpg';
const String globeDark = 'assets/2k_earth-night.jpg';

enum RoomState { none, wait, owner, joiner }
final ValueNotifier<RoomState> roomState = ValueNotifier(RoomState.none);

//TODO: Refactor app to use User Model
User currentUser = User();
Game currentGame = Game(lobbyId: '', totalRounds: 1, timeLimit: 60);

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
              //To remove the debug banner
              debugShowCheckedModeBanner: false,
              theme: MaterialTheme(Theme
                  .of(context)
                  .textTheme)
                  .theme(MaterialTheme.lightScheme()),
              darkTheme: MaterialTheme(Theme
                  .of(context)
                  .textTheme)
                  .theme(MaterialTheme.darkScheme()),
              themeMode: mode,
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
    await Future.delayed(Duration(seconds: 2)); // Optional delay for better UX
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('x-auth-token');
    globeEnabled = prefs.getBool('globeEnabled') ?? true;

    if (sessionId != null) {
      currentUser = User(username: prefs.getString('username'), sessionId: prefs.getString('sessionId'));
      context.read<UsersServices>().loginUser(currentUser.username??'', prefs.getString('password')??'');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      currentUser.clear();
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


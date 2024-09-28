import 'package:direction_guesser/theme.dart';
import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: MaterialTheme(Theme.of(context).textTheme).theme(MaterialTheme.lightScheme()),
        darkTheme: MaterialTheme(Theme.of(context).textTheme).theme(MaterialTheme.darkScheme()),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute, 
      initialRoute: CheckSessionStatus() ? '/home' : '/login'
    );
  }
}

bool CheckSessionStatus(){
  // Check if the user is logged in
  // If the user is logged in, return true
  // If the user is not logged in, return false
  //TODO: Implement this function
  return false;
}
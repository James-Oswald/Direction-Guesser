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
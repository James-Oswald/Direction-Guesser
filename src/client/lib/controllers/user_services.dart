import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersServices {

  String serverUrl = 'http://localhost:8080'; //localhost
  //String serverUrl = 'http://10.0.2.2:8080'; //Android emulator
  //String serverUrl = 'http://dirg.ieeeualbany.org'; //Server

  Future<bool> loginUser(String username, String password) async {
    final url = Uri.parse('$serverUrl/api/auth/');

    final body = jsonEncode({
      'sign_in': {'username': username, 'password': password}
    });

    // Send POST request to /login
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/JSON'},
          body: body,
        )
        .timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sessionId = response.body;

      // Store the session ID temporarily using shared preferences library in the future will move to user model
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', sessionId);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('x-auth-token');

    await prefs.remove('x-auth-token');
    if (sessionId == null) {
      //No session ID found, user is already logged out
      return false;
    }

    final url = Uri.parse('$serverUrl/api/auth/');

    // Send POST request to /logout with session ID in headers
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': '$sessionId',
      },
    );

    if (response.statusCode == 200) {
      // Remove session ID from shared preferences
      await prefs.remove('x-auth-token');
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getUserData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('x-auth-token');

    if (sessionId == null) {
      //No session ID found, user needs to login
      return false;
    }

    final url = Uri.parse('$serverUrl/api/user/$username');

    // Send GET request with session ID in headers
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': '$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      print('User data: $userData');
      //TODO: Store user data in a model class and in shared preferences
      return true;
    } else {
      return false;
    }
  }

  Future<bool> registerUser(String username, String email, String password, String? age, String? gender) async {
    final url = Uri.parse('$serverUrl/api/auth/');

    // Create JSON body for the request
    final body = jsonEncode({
      'sign_up': {'username': username, 'email': email, 'password': password}
    });

    // Send POST request to /user/create
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

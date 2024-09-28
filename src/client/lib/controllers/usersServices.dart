import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class usersServices{

  Future<bool> loginUser(String username, String password) async {

    final url = Uri.parse('http://10.0.2.2:8080/users/login');

    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    // Send POST request to /login
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final sessionId = data['session_id'];

      // Store the session ID in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', sessionId);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> logoutUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');

    await prefs.remove('session_id');
    if (sessionId == null) {
      //No session ID found, user is already logged out
      return false;
    }

    final url = Uri.parse('http://10.0.2.2:8080/users/$username/logout');

    // Send POST request to /logout with session ID in headers
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionId',
      },
    );

    if (response.statusCode == 200) {
      // Remove session ID from shared preferences
      await prefs.remove('session_id');
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getUserData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');

    if (sessionId == null) {
    //No session ID found, user needs to login
      return false;
    }

    final url = Uri.parse('http://10.0.2.2:8080/users/$username/get_user_handler');

    // Send GET request with session ID in headers
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sessionId',
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
    final url = Uri.parse('http://10.0.2.2:8080/users/$username/create_user_handler');
    
    // Create JSON body for the request
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'age':  age,
      'gender': gender
    });

    // Send POST request to /user/create
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

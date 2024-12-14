import 'dart:convert';
import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameServices {

  //String serverUrl = 'http://localhost:8080';
  //String serverUrl = 'http://10.0.2.2:8080';
  String serverUrl = 'http://dirg.ieeeualbany.org';

  Future<String> randomCity(double latitude, double longitude) async {
    final url = Uri.parse('$serverUrl/api/process');

    final body = jsonEncode({
        'calculate_nearby': {'user_lat': '$longitude', 'user_lon': '$latitude', 'range': 20}
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: body,
    );

    /* e.g. [name: "Osterhout Cemetery", coord: {-73.80309, 42.57871}] */
    return response.body;
  }

  Future<List<Map<String, dynamic>>> getRandomCities(String latitude, String longitude, int amount) async {
    final url = Uri.parse('$serverUrl/api/process');

    //latitude and longitude are reversed in the API
    final body = jsonEncode({
        'calculate_nearby': {'user_lat': '$longitude', 'user_lon': '$latitude', 'range': 20}
    });

    List<Map<String, dynamic>> cities = [];

    for (int i = 0; i < amount; i++) {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/JSON'},
        body: body,
      );
      final data = jsonDecode(response.body);

      String name= data[0][1]; // Name
      dynamic longitude= data[1][1][0]; // Longitude
      dynamic latitude= data[1][1][1];
      
      cities.add({
          "name": name, // Name
          "longitude": longitude, // Longitude
          "latitude": latitude // Latitude
        });
    }

    return cities;
  }

  Future<bool> sendGuess(List<double> user_bearing, double user_lat, double user_lon, double target_lat, double target_lon) async {
    // TODO: we haven't decided on an endpoint for this yet
    final url = Uri.parse('$serverUrl/api/process');
    // TODO BUG: User bearing is an array of bearings, sometimes it is empty. For now, we will sending a fake bearing in its fake
    double bearing = 0.0;
    if (user_bearing != null && user_bearing.isNotEmpty) {
      bearing = user_bearing.reduce((a, b) => a + b) / user_bearing.length;
    }
    // create the body with all of the information needed for a guess
    final body = jsonEncode({
      'calculate_score': {
        'user_bearing': bearing,
        'user_lat': user_lat,
        'user_lon': user_lon,
        'target_lat': target_lat,
        'target_lon': target_lon
      }
    });

    // Send POST request to /game/guess TODO: update endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: body,
    );

    // TODO: use a logger

    // TODO: again, we haven't decided on a game API spec, this is just placeholder
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      /* e.g. 93 */
      final score = data[0][1];
      /* e.g. degrees off */
      final deg_off = data[1][1];
      // Format deg_off to two decimal places and add the degree symbol
      final formattedDegOff = "${deg_off.toStringAsFixed(2)}°";

      // Store the resulting score in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('score', score.toString());
      await prefs.setString('deg_off', formattedDegOff);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> createLobby() async {
    final url = Uri.parse('$serverUrl/api/user');

    final prefs = await SharedPreferences.getInstance();
    final String? sessionId = prefs.getString('x-auth-token');
    final String body = jsonEncode({
      'lobby_create': {}
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/JSON',
        'x-auth-token': sessionId ?? ''
        },
      body: body,
    );

    if (response.statusCode == 200) {
      prefs.setString('currentLobby', jsonDecode(response.body).toString());
      bool success = await joinLobby(jsonDecode(response.body).toString());
      return success;
    } else {
      return false;
    }
  }

  Future<bool> joinLobby(String lobbyName) async {
    final url = Uri.parse('$serverUrl/api/user');
    final pref = await SharedPreferences.getInstance();

    final body = jsonEncode({
      'lobby_join': {'id': lobbyName}
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON',
                'x-auth-token': pref.getString('x-auth-token') ?? ''},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> lobbySubmitGuess(List<double> user_bearing, double user_lat, double user_lon, double target_lat, double target_lon) async {
    final url = Uri.parse('$serverUrl/api/user');
    final prefs = await SharedPreferences.getInstance();

    // TODO BUG: User bearing is an array of bearings, sometimes it is empty. For now, we will sending a fake bearing in its fake
    double bearing = 0.0;
    if (user_bearing != null && user_bearing.isNotEmpty) {
      bearing = user_bearing.reduce((a, b) => a + b) / user_bearing.length;
    }
    // create the body with all of the information needed for a guess
    final body = jsonEncode({
      'lobby_submit': {
        'user_bearing': bearing,
        'user_lat': user_lat,
        'user_lon': user_lon,
        'target_lat': target_lat,
        'target_lon': target_lon
      }
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON',
                'x-auth-token': prefs.getString('x-auth-token') ?? ''},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getLobbyInfo(String lobbyName) async {
    final url = Uri.parse('$serverUrl/api/lobby/$lobbyName');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/JSON'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Lobby data: $data');
    }
    return false;
  }

  Future<bool> lobbyReady() async {
    final url = Uri.parse('$serverUrl/api/user/');
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: jsonEncode({
        'lobby_ready': {}
      }),
    );

    if (response.statusCode == 200) {
      prefs.setString('currentLobbyLocation', response.body);
      return true;
    } else {
      return false;
    }
  }
}

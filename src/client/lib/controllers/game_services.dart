import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameServices {

  String serverUrl = 'http://localhost:8080';
  //String serverUrl = 'http://10.0.2.2:8080';
  //String serverUrl = 'http://dirg.ieeeualbany.org';

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
    final double avg_user_bearing = user_bearing.reduce((a, b) => a + b) / user_bearing.length;
    // create the body with all of the information needed for a guess
    final body = jsonEncode({
      'calculate_score': {
        'user_bearing': avg_user_bearing,
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

      // Store the resulting score in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('score', score.toString());
      await prefs.setString('deg_off', deg_off.toString());

      return true;
    } else {
      return false;
    }
  }

  Future<bool> createLobby(String lobbyName) async {
    final url = Uri.parse('$serverUrl/api/lobby');

    final body = jsonEncode({
      'start_link': {
        'name': lobbyName
      }
    });

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

  Future<bool> joinLobby(String lobbyName) async {
    final url = Uri.parse('$serverUrl/api/lobby');

    final body = jsonEncode({
      'join_link': {
        'name': lobbyName
      }
    });

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

  Future<bool> readyUp() async {
    final url = Uri.parse('$serverUrl/api/lobby/ready');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

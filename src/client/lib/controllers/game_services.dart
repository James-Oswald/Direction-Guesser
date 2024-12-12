import 'dart:convert';
import 'dart:ffi';

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
      jsonDecode(response.body).map((data) {
        return {
          "name": data["name"],
          "latitude": data["coord"][0], // Longitude
          "longitude": data["coord"][1], // Latitude
        };
      }).toList();
    }

    return cities;
  }

  Future<bool> sendGuess(List<double> user_bearing, double user_lat, double user_lon, double target_lat, double target_lon) async {
    // TODO: we haven't decided on an endpoint for this yet
    final url = Uri.parse('$serverUrl/game/guess');

    // create the body with all of the information needed for a guess
    final body = jsonEncode({
      'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': headings
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
      final score = data;

      // Store the resulting score in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('score', score);

      return true;
    } else {
      return false;
    }
  }
}

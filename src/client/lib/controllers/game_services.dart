import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameServices {
  Future<String> randomCity(double latitude, double longitude) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/process');

    final body = jsonEncode({
        'calculate_nearby': {'user_lat': latitude, 'user_lon': longitude, 'range': 20}
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: body,
    );

    print(response.statusCode);
    print(response.body);

    /* e.g. [name: "Osterhout Cemetery", coord: {-73.80309, 42.57871}] */
    return response.body;
  }

  Future<bool> sendGuess(List<double> user_bearing, double user_lat, double user_lon, double target_lat, double target_lon) async {
    // TODO: we haven't decided on an endpoint for this yet
    final url = Uri.parse('http://10.0.2.2:8080/api/process');

    // create the body with all of the information needed for a guess
    final body = jsonEncode({
        'user_bearing': user_bearing,
        'user_lat': user_lat,
        'user_lon': user_lon,
        'target_lat': target_lat,
        'target_lon': target_lon
    });

    // Send POST request to /game/guess TODO: update endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: body,
    );

    // TODO: use a logger
    print(response.statusCode);
    print(response.body);

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

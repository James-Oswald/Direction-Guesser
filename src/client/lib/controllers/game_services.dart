import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GameServices {
  Future<bool> sendGuess(UnsignedInt sessionId, double latitude,
      double longitude, double heading) async {
    // TODO: we haven't decided on an endpoint for this yet
    final url = Uri.parse('http://10.0.2.2:8080/game/guess');

    final body = jsonEncode({
      'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading
    });

    // Send POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/JSON'},
      body: body,
    );

    print(response.statusCode);
    print(response.body);

    // TODO: again, we haven't decided on a game API spec
    // this is just placeholder
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final score = data['score'];

      // Store the session ID in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('score', score);

      return true;
    } else {
      return false;
    }
  }
}

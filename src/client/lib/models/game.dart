// Purpose: Model for game
// Can use bused in the future for further customization of the game
import 'dart:convert';

class Game{
  String lobbyId;
  int totalRounds;
  int roundNumber = 0;
  int timeLimit;
  //single player scores
  Map<String, Map<String, String>> scores = {}; 
  //add range when backend is ready
  //int range;

  // currently contains maps of key - username, value - map of
  //('location' - ), 
  //('ready' - 'true'/'false'),  
  //('score'- 'score''deg_off'),
  //('username' - '')
  Map<String, dynamic> playerInfo = {};
  List<MapEntry<String, List<dynamic>>> playerScoresSorted = [];
  List<Map<String, dynamic>> citiesList = [];
  bool isMultiplayer = false;

  Game({required this.lobbyId, required this.totalRounds, required this.timeLimit});

  void incrementRound() {
    roundNumber++;
  }
  void addCities(Map<String, dynamic> cities) {
    citiesList.add(cities);
  }
  void popCity() {
    citiesList.removeAt(0);
  }
  void addLobbyInfo(String json){
    playerInfo = jsonDecode(json);
  }
  
  //TODO: add exception handling
  dynamic getUserInfo(String username){
    return playerInfo[username];
  }

  bool getUserReadyStatus(String username){
    return playerInfo[username]['ready'];
  }

  //returns a list of 2 strings, score and deg_off 
  List<String> getUserScore(String username){
    return [
      playerInfo[username]['score'][0],
      playerInfo[username]['score'][1]
    ]; //playerInfo[username]['score'][];
  }

  //TODO: when backend is sending back generalized locations of users send 
  //back a map of usernames and coordinates
  List<dynamic> getPlayers(){
    return playerInfo.entries.map((e) => e.value['username']).toList();
  }

  int getNumPlayers(){
    return playerInfo.length;
  }

  //TODO: when backend is update with round logic and multiplayer customization 
  //other variables can be set using the sent json map such as
  // ragne, timeLimit, etc.
  void setLobbyUserInfo(Map<String, dynamic> info){
    playerInfo = info['users'];
  }

  List<MapEntry<String, List<dynamic>>> getFinalScores(){
    final List<MapEntry<String, List<dynamic>>> sortedList = [];
    for (var entry in playerInfo.entries) {
      final username = entry.value["username"];
      final List<dynamic> playerScores = entry.value["score"];
      int score = playerScores[0][1];
      double degOff = playerScores[1][1];

      if (score != null && degOff != null) {
        sortedList.add(MapEntry(username, [score, degOff]));
      }else{
        sortedList.add(MapEntry(username, [0, 360.0]));
      }
      
    }
    sortedList.sort((a, b) => b.value[0].compareTo(a.value[0]));
    playerScoresSorted = sortedList;
    return sortedList;
  }

  void clear() {
    lobbyId = '';
    totalRounds = 1;
    scores.clear();
    citiesList.clear();
    playerInfo.clear();
    roundNumber = 0;
    isMultiplayer = false;
  }
}
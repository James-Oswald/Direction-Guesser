// Purpose: Model for game
// Can use bused in the future for further customization of the game
class Game{
  String lobbyId;
  int totalRounds;
  int roundNumber = 0;
  int timeLimit;
  Map<String, Map<String, String>> scores = {};
  Map<String, List<String>> playerScores = {};
  Map<String, String> playerStatus = {};
  List<Map<String, dynamic>> citiesList = [];
  bool isMultiplayer = false;

  Game({required this.lobbyId, required this.totalRounds, required this.timeLimit});

  void setPlayerStatus(String player, String status) {
    playerStatus[player] = status;
  }
  String getPlayerStatus(String player) {
    return playerStatus[player]!;
  }
  void setPlayerScore(String player, int roundNumber, String score) {
    playerScores[player]![roundNumber] = score;
  }
  List<String>? getPlayerScore(String player) {
    return playerScores[player];
  }
  void incrementRound() {
    roundNumber++;
  }
  void addCities(Map<String, dynamic> cities) {
    citiesList.add(cities);
  }
  void popCity() {
    citiesList.removeAt(0);
  }
  void addScore(String city, Map<String, String> score) {
    //playerScores[city] = score;
  }
  Map<String, String>? getScore(String city) {
    //return scores[city]!;
    return null;
  }
  void clear() {
    playerScores.clear();
    playerStatus.clear();
    citiesList.clear();
    roundNumber = 0;
  }
}
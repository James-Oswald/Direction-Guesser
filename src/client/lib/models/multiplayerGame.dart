class Multiplayergame{
  String lobbyId;
  int roundNumber;
  int timeLimit;
  Map<String, List<String>> playerScores = {};
  Map<String, String> playerStatus = {};
  List<Map<String, dynamic>> citiesList = [];

  Multiplayergame({
    required this.lobbyId, required this.roundNumber, required this.timeLimit
  });

  void addCities(Map<String, dynamic> cities){
    citiesList.add(cities);
  }

  void addLobbyInfo(String json){
  }
}
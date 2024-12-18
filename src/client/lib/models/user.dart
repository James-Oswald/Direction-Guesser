// This file contains the User model class which is used to represent a user in the application. Can be used in the future to store other information about the user such as their score, level, etc.
class User {
  String? username;
  String? sessionId;

  User({this.username, this.sessionId});

  // Factory method to create a User from JSON data not necessary needed since the user object will likely made only once.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['username'] as String,
        sessionId: json['sessionId'] as String
    );
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'sessionId': sessionId
    };
  }

  void clear() {
    username = null;
    sessionId = null;
  }
}
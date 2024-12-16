import 'dart:async';

import 'package:direction_guesser/widgets/leaderboard_card.dart';
import 'package:direction_guesser/widgets/points_pill.dart';
import 'package:direction_guesser/widgets/permissions_denied_card.dart';
import 'package:direction_guesser/widgets/missing_device_card.dart';
import 'package:direction_guesser/controllers/user_services.dart';
import 'package:direction_guesser/controllers/game_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../main.dart';
import '../widgets/text_entry_pill.dart';

enum PermissionsState {
  okay,
  gpsServicesUnavailable,
  locationDenied
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController roomCodeController = TextEditingController();
  ValueNotifier<PermissionsState> permissionState = ValueNotifier(PermissionsState.okay);

  String roomCode = "";
  int playersInRoom = 0;

  @override initState() {
    super.initState();
    checkSensors();
  }

  void _logout() async {
    bool success = await context.read<UsersServices>().logoutUser();
    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to logout, please try again later.")));
    }
  }

  void _getLobbyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String lobbyName = prefs.getString('currentLobby') ?? "";
    await context.read<GameServices>().getLobbyInfo();
    setState(() {});
  }

  void _lobbyReady() async {
    roomState.value = RoomState.wait;
    setState(() {});
    var location = await Geolocator.getCurrentPosition();
    bool success = await context.read<GameServices>().lobbyReady(location.latitude.toStringAsFixed(2), location.longitude.toStringAsFixed(2));
    if (success) {
      Navigator.pushNamed(context, '/guess');
    } else {
      roomState.value = RoomState.joiner;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to start match, please try again later.")));
    }
  }

  void _lobbyReadyOwner() async {
    roomState.value = RoomState.wait;
    setState(() {});
    var location = await Geolocator.getCurrentPosition();
    bool success = await context.read<GameServices>().lobbyReady(location.latitude.toStringAsFixed(2), location.longitude.toStringAsFixed(2));
    if (success) {
      Navigator.pushNamed(context, '/guess');
    } else {
      roomState.value = RoomState.owner;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to start match, please try again later.")));
    }
  }

  void _createLobby() async {
    bool success = await context.read<GameServices>().createLobby();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      roomCode = prefs.getString('currentLobby') ?? "";
      roomState.value = RoomState.owner;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to create room, please try again later.")));
    }
  }

  void _joinLobby() async {
    bool success = await context.read<GameServices>().joinLobby(roomCode);
    if (success) {
      roomState.value = RoomState.joiner;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to join room, please try again later.")));
    }

  }

  void checkSensors() async{
    await Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (permissionState.value == PermissionsState.okay) {
          permissionState.value = PermissionsState.locationDenied;
          return;
        }
        return;
      } else if (permission == LocationPermission.unableToDetermine) {
        permissionState.value = PermissionsState.gpsServicesUnavailable;
        return;
      }
      // made it through every check, permissions are good
      permissionState.value = PermissionsState.okay;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFFFAF8FF)
                    : Color(0xFF121318),
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFF495D92)
                    : Color(0xFF151B2C)
              ]),
        ),
        child: PopScope(
          canPop: false,
          child: ValueListenableBuilder<PermissionsState>(
            valueListenable: permissionState,
            builder: (_, PermissionsState permissionState, child) {
              if (permissionState == PermissionsState.okay) {
                return mainUI(context);
              } else if (permissionState == PermissionsState.gpsServicesUnavailable) {
                return MissingDeviceCard(
                        mainText:
                            "Your device is missing either GPS or a compass.",
                        subText: "Without these, you are unable to play.");;
              } else if (permissionState == PermissionsState.locationDenied) {
                return needLocationsUI();
              } else {
                return needLocationsUI();
              }
            },
          ),
        ));
  }

  Widget mainUI(BuildContext context){
    return ValueListenableBuilder<RoomState>(
            valueListenable: roomState,
            builder: (_, RoomState roomState, child) {
              if (roomState == RoomState.owner) {
                return ownerUI(context);
              } else if (roomState == RoomState.joiner) {
                return joinerUI(context);
              } else if (roomState == RoomState.wait) {
                return waitUI(context);
              } else {
                return noRoomUI(context);
              }
            });
  }

  Widget noRoomUI(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SizedBox(height: 64),
              PointsPill(points: 15827),
              SizedBox(height: 32),
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                LeaderboardCard(),
                Spacer(),
                FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/guess');
                    },
                    child: Text("Single Player Match")),
                SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 64,
                  child: TextEntryPill(
                    controller: roomCodeController,
                    icon: Icon(
                      Icons.qr_code_2_rounded,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    hintText: "room code",
                    obscured: false,
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FilledButton(
                      onPressed: () {
                        // TODO: create room
                        _createLobby();
                        roomCode = roomCodeController.text;
                        setState(() {});
                      },
                      child: Text("Create Room")),
                  SizedBox(width: 16),
                  FilledButton(
                      onPressed: () {
                        // TODO: join room
                        _joinLobby();
                        roomCode = roomCodeController.text;
                        setState(() {});
                      },
                      child: Text("Join Room")),
                ]),
                Spacer(),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/settings')},
                          child: Icon(
                            Icons.settings_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          )),
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/login')},
                          // TODO: implement logout
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          )),
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/profile')},
                          child: Icon(
                            Icons.person_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ))
                    ]),
                SizedBox(height: 16)
              ]))
            ])));
  }

  Widget ownerUI(BuildContext context) {
    TextStyle labelStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SizedBox(height: 64),
              PointsPill(points: 15827),
              SizedBox(height: 32),
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                LeaderboardCard(),
                Spacer(),
                Text("Current room: $roomCode", style: labelStyle),
                SizedBox(height: 8),
                Text("Players in room: $playersInRoom", style: labelStyle),
                SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FilledButton(
                      onPressed: () {
                        // TODO: destroy room
                        roomState.value = RoomState.none;
                      },
                      child: Text("Destroy Room")),
                  SizedBox(width: 16),
                  FilledButton(
                      onPressed: () {
                        // TODO: make all players start the match?
                        _lobbyReadyOwner();
                      },
                      child: Text("Start Match")),
                ]),
                Spacer(),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/settings')},
                          child: Icon(
                            Icons.settings_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          )),
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/login')},
                          // TODO: implement logout
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          )),
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/profile')},
                          child: Icon(
                            Icons.person_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ))
                    ]),
                SizedBox(height: 16)
              ]))
            ])));
  }

  Widget waitUI(BuildContext) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget joinerUI(BuildContext context) {
    TextStyle labelStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              SizedBox(height: 64),
              PointsPill(points: 15827),
              SizedBox(height: 32),
              Expanded(
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                LeaderboardCard(),
                SizedBox(height: 32),
                Text("Current room: $roomCode", style: labelStyle),
                SizedBox(height: 8),
                Text("Players in room: $playersInRoom", style: labelStyle),
                SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FilledButton(
                      onPressed: () {
                        // TODO: destroy room
                        roomState.value = RoomState.none;
                      },
                      child: Text("Leave Room")),
                  FilledButton(
                      onPressed: () {
                        // TODO: make all players start the match?
                        _lobbyReady();
                      },
                      child: Text("Ready!")),
                ]),
                SizedBox(height: 16),
                Text("Waiting for match to start...", style: labelStyle),
                Spacer(),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/settings')},
                          child: Icon(
                            Icons.settings_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          )),
                      FilledButton.tonal(
                          onPressed: () =>
                              {
                                _lobbyReady()
                              },
                          // TODO: implement logout
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          )),
                      FilledButton.tonal(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/profile')},
                          child: Icon(
                            Icons.person_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ))
                    ]),
                SizedBox(height: 16)
              ]))
            ])));
  }
  Container needLocationsUI() {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFFFAF8FF)
                    : Color(0xFF121318),
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFF495D92)
                    : Color(0xFF151B2C)
              ]),
        ),
        child: PermissionsDeniedCard(
            mainText:
                "Please enable location permissions for Direction Guesser from your settings",
            subText:
                "Location permissions are needed to determine your coordinates and heading.",
            onPressed: Geolocator.openAppSettings));
  }
}

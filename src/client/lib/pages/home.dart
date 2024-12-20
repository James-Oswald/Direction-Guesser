import 'dart:async';
import 'package:direction_guesser/widgets/points_pill.dart';
import 'package:direction_guesser/widgets/permissions_denied_card.dart';
import 'package:direction_guesser/widgets/missing_device_card.dart';
import 'package:direction_guesser/controllers/user_services.dart';
import 'package:direction_guesser/controllers/game_services.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'dart:math';

import '../main.dart';
import '../widgets/text_entry_pill.dart';

enum PermissionsState { okay, gpsServicesUnavailable, locationDenied }
const String globeLight = 'assets/2k_earth-day.jpg';
const String globeDark = 'assets/2k_earth-night.jpg';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController roomCodeController = TextEditingController();
  ValueNotifier<PermissionsState> permissionState =
      ValueNotifier(PermissionsState.okay);
  late AppLifecycleListener lifecycleListener;
    String globeMode = globeDark;
  late FlutterEarthGlobeController globeController =
      FlutterEarthGlobeController(
          isRotating: true,
          rotationSpeed: 0.05,
          surface: Image.asset(globeMode).image);

  String roomCode = "";
  int playersInRoom = 0;
  final random = Random();


  @override
  initState() {
    super.initState();
    //
    globeMode = themeNotifier.value == ThemeMode.dark ? globeDark : globeLight;
    globeController = FlutterEarthGlobeController(
        isRotating: true,
        rotationSpeed: 0.05,
        surface: Image.asset(globeMode).image,
        background: Image.asset('assets/2k_stars.jpg').image
        );
    lifecycleListener = AppLifecycleListener(onRestart: checkSensors);
    checkSensors();
  }

  @override

  void _logout() async {
    bool success = await context.read<UsersServices>().logoutUser();
    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to logout, please try again later.")));
    }
  }

  void _getLobbyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String lobbyName = prefs.getString('currentLobby') ?? "";
    Map<String, dynamic> currentLobbyInfo = await context.read<GameServices>().getLobbyInfo();
    currentGame.setLobbyUserInfo(currentLobbyInfo);
    playersInRoom = currentGame.getPlayers().length;
    //addUsersToGlobe();
    setState(() {});
  }

  void _lobbyReady() async {
    roomState.value = RoomState.wait;
    setState(() {});
    var location = await Geolocator.getCurrentPosition();
    currentGame.citiesList = await context.read<GameServices>().lobbyReady(
        location.latitude.toStringAsFixed(2),
        location.longitude.toStringAsFixed(2));
    if (currentGame.citiesList.isNotEmpty) {
      Navigator.pushNamed(context, '/guess');
    } else {
      roomState.value = RoomState.joiner;
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to start match, please try again later.")));
      });
    }
  }

  void _lobbyReadyOwner() async {
    roomState.value = RoomState.wait;
    setState(() {});
    var location = await Geolocator.getCurrentPosition();
    currentGame.citiesList = await context.read<GameServices>().lobbyReady(
        location.latitude.toStringAsFixed(2),
        location.longitude.toStringAsFixed(2));
    if (currentGame.citiesList.isNotEmpty) {
      Navigator.pushNamed(context, '/guess');
    } else {
      roomState.value = RoomState.owner;
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to start match, please try again later.")));
      });
    }
  }

  void _createLobby() async {
    bool success = await context.read<GameServices>().createLobby();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      currentGame.lobbyId = prefs.getString('currentLobby') ?? "";
      roomCode = currentGame.lobbyId;
      currentGame.isMultiplayer = true;
      roomState.value = RoomState.owner;
      _getLobbyInfo();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to create room, please try again later.")));
    }
  }

  void _joinLobby() async {
    bool success = await context.read<GameServices>().joinLobby(roomCode);
    if (success) {
      currentGame.lobbyId = roomCode;
      currentGame.isMultiplayer = true;
      roomState.value = RoomState.joiner;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to join room, please try again later.")));
    }
  }

  //TODO: Refact/ Move all sensors to separate page and check on app start and on game begin
  void checkSensors() async {
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

  //Add users to globe
  //TODO: When Backend is capable of sending general location data of user change 
  // now adds randomly
  void addUsersToGlobe() {
    List<Point> currentPoints = globeController.points;
    List<dynamic> users = currentGame.getPlayers();
    //games starts and users are added
    if (users.length == 0) {
      for (String user in users) {
        globeController.addPoint(
            Point(
                id: user,
                label: user,
                isLabelVisible: true,
                coordinates: GlobeCoordinates(-90 + (random.nextDouble() * 180), -180 + (random.nextDouble() * 360)),
                labelTextStyle: TextStyle(color: Colors.white)),
                );
      }
    } else {
      //remove users that are no longer in the room
      for (Point point in currentPoints) {
        if (!users.contains(point.label)) {
          globeController.removePoint(point.id);
        }
      }
      //add users that are not in the room
      for (String user in users) {
        bool found = false;
        for (Point point in currentPoints) {
          if (point.label == user) {
            found = true;
          }
        }
        if (!found) {
          globeController.addPoint(
            Point(
                id: user,
                label: user,
                isLabelVisible: true,
                coordinates: GlobeCoordinates(-90 + (random.nextDouble() * 180), -180 + (random.nextDouble() * 360)),
                labelTextStyle: TextStyle(color: Colors.white)),
                );
        }
      }
    }
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
              } else if (permissionState ==
                  PermissionsState.gpsServicesUnavailable) {
                checkSensors();
                return MissingDeviceCard(
                    mainText: "Your device is missing either GPS or a compass.",
                    subText: "Without these, you are unable to play.");
                ;
              } else {
                checkSensors();
                return needLocationsUI();
              }
            },
          ),
        ));
  }

  Widget mainUI(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
                child: globeEnabled ? FlutterEarthGlobe(
              controller: globeController,
              radius: 60,
              //TODO: temporary fix globe is not centered
              //will need to inspect widget tree to see why
              alignment: Alignment(0, -0.4),
            ) : Container()),
            Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 64),
                      PointsPill(points: 15827),
                      SizedBox(height: 32),
                      if (!globeEnabled)
                        Image.asset('assets/logo.png', height: 200),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                            Spacer(),
                            Spacer(),
                            Spacer(),
                            ValueListenableBuilder<RoomState>(
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
                                }),
                            Spacer(),
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  FilledButton.tonal(
                                      onPressed: () => {
                                            Navigator.pushNamed(
                                                context, '/settings').then((_) => {
                                                  setState(() {})
                                                })
                                          },
                                      child: Icon(
                                        Icons.settings_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      )),
                                  FilledButton.tonal(
                                      //untested
                                      onPressed: () => {_logout()},
                                      child: Icon(
                                        Icons.exit_to_app_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      )),
                                  FilledButton.tonal(
                                      onPressed: () => {
                                            Navigator.pushNamed(
                                                context, '/profile')
                                          },
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ))
                                ]),
                            SizedBox(height: 16)
                          ]))
                    ]))
          ],
        ));
  }

  Widget noRoomUI(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          FilledButton(
              onPressed: () {
                currentGame.isMultiplayer = false;
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
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: FilledButton(
                        onPressed: () {
                          // TODO: create room
                          _createLobby();
                          roomCode = roomCodeController.text;
                          setState(() {});
                        },
                        child: Text("Create Room")),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: FilledButton(
                        onPressed: () {
                          // TODO: join room
                          roomCode = roomCodeController.text;
                          _joinLobby();
                          setState(() {});
                        },
                        child: Text("Join Room")),
                  ),
                ]),
          )
        ]);
  }

  Widget ownerUI(BuildContext context) {
    TextStyle labelStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface);

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text("Current room: $roomCode", style: labelStyle),
      SizedBox(height: 8),
      Text("Players in room: $playersInRoom", style: labelStyle),
      SizedBox(height: 16),
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            flex: 1,
            child: FilledButton(
                onPressed: () {
                  // TODO: destroy room
                  roomState.value = RoomState.none;
                  currentGame.isMultiplayer = false;
                  currentGame.clear();
                },
                child: Center(child: Text("Destroy Room"))),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: FilledButton(
                onPressed: () {
                  // TODO: make all players start the match?
                  _lobbyReadyOwner();
                },
                child: Center(child: Text("Start Match"))),
          ),
        ]),
      ),
    ]);
  }

  Widget joinerUI(BuildContext context) {
    TextStyle labelStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Current room: $roomCode", style: labelStyle),
          SizedBox(height: 8),
          Text("Players in room: $playersInRoom", style: labelStyle),
          SizedBox(height: 16),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                flex: 1,
                child: FilledButton(
                    onPressed: () {
                      // TODO: destroy room
                      roomState.value = RoomState.none;
                      currentGame.isMultiplayer = false;
                      currentGame.clear();
                    },
                    child: Text("Leave Room")),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: FilledButton(
                    onPressed: () {
                      // TODO: make all players start the match?
                      _lobbyReady();
                    },
                    child: Text("Ready!")),
              ),
            ]),
          ),
          SizedBox(height: 16),
          Text("Waiting for match to start...", style: labelStyle),
        ]);
  }

  Widget waitUI(BuildContext) {
    return CircularProgressIndicator();
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

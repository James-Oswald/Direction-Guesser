import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/game_services.dart';
import '../main.dart';
import '../widgets/permissions_card.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  State<GuessPage> createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  late CameraController controller;
  late Future<LocationPermission> locationPermissions;
  double latitude = 0.0;
  double longitude = 0.0;
  double heading = 0.0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("Camera access denied.");
            break;
          default:
            print("Error occurred.");
            break;
        }
      }
    });
    locationPermissions = getLocationPermissions();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      // cannot find a camera or permissions were denied
      return Scaffold(body: Builder(builder: (context) {
        return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme
                        .of(context)
                        .brightness == Brightness.light
                        ? Color(0xFFFAF8FF)
                        : Color(0xFF121318),
                    Theme
                        .of(context)
                        .brightness == Brightness.light
                        ? Color(0xFF495D92)
                        : Color(0xFF151B2C)
                  ]),
            ),
            child: PermissionsCard(
                mainText:
                "Please enable camera permissions for Direction Guesser from your settings",
                subText:
                "If your device does not have a camera, you are unable to play this game."));
      }));
    } else {
      return FutureBuilder<LocationPermission>(
          future: getLocationPermissions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.data == LocationPermission.denied ||
                snapshot.data == LocationPermission.deniedForever) {
              return Scaffold(body: Builder(builder: (context) {
                return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme
                                .of(context)
                                .brightness == Brightness.light
                                ? Color(0xFFFAF8FF)
                                : Color(0xFF121318),
                            Theme
                                .of(context)
                                .brightness == Brightness.light
                                ? Color(0xFF495D92)
                                : Color(0xFF151B2C)
                          ]),
                    ),
                    child: PermissionsCard(
                        mainText:
                        "Please enable location permissions for Direction Guesser from your settings",
                        subText:
                        "Location permissions are needed to determine your coordinates and heading."));
              }));
            } else {
              return Column(children: [
                Spacer(),
                Stack(children: [
                  Center(child: CameraPreview(controller)),
                  // Use a row to center the vertical divider in the center of the
                  // screen regardless of screen dimensions
                  Center(
                    child: VerticalDivider(color: Colors.red, thickness: 2),
                  )
                ]),
                FilledButton(
                    onPressed: () => submitGuess(context),
                    child: Text("Get Position")),
                Text(
                    "Current position: $latitude : $longitude\nCurrent heading: $heading",
                    style: TextStyle(fontSize: 12)),
                Spacer()
              ]);
            }
          });
    }
  }

  Future<void> submitGuess(BuildContext context) async {
    var location = await Geolocator.getCurrentPosition();
    var direction = await FlutterCompass.events?.first;
    setState(() {
      latitude = location.latitude;
      longitude = location.longitude;
      heading = (direction?.heading)!;
    });

    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    bool guessSentSuccessfully = await context.read<GameServices>().sendGuess(
      // TODO: this cast should go away when we refactor to uints for session_id
        sessionId as UnsignedInt,
        latitude,
        longitude,
        heading
    );

    // Check the result of sending the guess
    if (guessSentSuccessfully) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guess successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guess unsuccessful!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<LocationPermission> getLocationPermissions() async {
    return await Geolocator.checkPermission();
  }
}
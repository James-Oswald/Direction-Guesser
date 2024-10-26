import 'dart:ffi';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/game_services.dart';
import '../main.dart';
import '../widgets/permissions_denied_card.dart';

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
                    "Please enable camera permissions for Direction Guesser from your settings",
                subText:
                    "Camera permissions are needed to display your surroundings when making a guess.",
                onPressed: Geolocator.openAppSettings));
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
              }));
            } else {
              return Scaffold(body: Builder(builder: (context) {
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
                    child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                              Spacer(),
                              Text(
                                  "Line up your guess using the camera as a guide.",
                                  style: TextStyle(
                                      fontStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.fontStyle,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.fontSize,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceTint)),
                              SizedBox(height: 16),
                              Center(
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                blurRadius: 8,
                                                offset: Offset(0, 8))
                                          ]),
                                      child: Stack(children: [
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: CameraPreview(controller)),
                                        Positioned.fill(
                                            child: Center(
                                                child: VerticalDivider(
                                                    color: Colors.red,
                                                    thickness: 2))),
                                      ]))),
                              SizedBox(height: 16),
                              FilledButton(
                                  onPressed: () => submitGuess(context),
                                  child: Text("Get Position")),
                              SizedBox(height: 16),
                              Text(
                                  "Current position: $latitude : $longitude\nCurrent heading: $heading",
                                  style: TextStyle(
                                      fontStyle: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.fontStyle,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.fontSize,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceTint)),
                              Spacer()
                            ]))));
              }));
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
        heading);

    // Check the result of sending the guess
    if (guessSentSuccessfully) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guess successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
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

import 'dart:async';
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

enum PermissionsState {
  okay,
  noCamera,
  noLocation,
  cameraDenied,
  locationDenied
}

class _GuessPageState extends State<GuessPage> {
  // set up a notifier for the permissions state
  ValueNotifier<PermissionsState> permissionState =
      ValueNotifier(PermissionsState.okay);
  late AppLifecycleListener lifecycleListener;
  bool _cameraInitialized = false;
  late CameraController controller;
  double latitude = 0.0;
  double longitude = 0.0;
  double heading = 0.0;

  @override
  void initState() {
    super.initState();
    // create a listener for lifecycle state changes
    // everytime the app is resumed or shown, we need to recheck permissions
    lifecycleListener = AppLifecycleListener(
        onResume: checkPermissions, onShow: checkPermissions);

    checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ValueListenableBuilder<PermissionsState>(
            valueListenable: permissionState,
            builder: (_, PermissionsState permissions, child) {
              print("currentPermission: $permissions");
              if (permissions == PermissionsState.cameraDenied) {
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
              } else if (permissions == PermissionsState.locationDenied) {
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
                          child:
                              Column(mainAxisSize: MainAxisSize.max, children: [
                        Spacer(),
                        Text("Line up your guess using the camera as a guide.",
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
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceTint)),
                        SizedBox(height: 16),
                        Center(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: Offset(0, 8))
                                    ]),
                                child: Stack(children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
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
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceTint)),
                        Spacer()
                      ]))));
            }));
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

  void checkPermissions() {
    print("permissionstate: $permissionState.value");
    // Check location permissions first
    Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        permissionState.value = PermissionsState.locationDenied;
        return;
      } else if (permission == LocationPermission.unableToDetermine) {
        permissionState.value = PermissionsState.noLocation;
        return;
      } else {
        // Now check camera permissions and initialize if needed
        if (!_cameraInitialized)
          initializeCamera();

        if (_cameraInitialized)
          permissionState.value = PermissionsState.okay;
      }
    });
    print("end permissionstate: $permissionState.value");
  }

  void initializeCamera() {
    if (_cameraInitialized) {
      return;
    }

    if (!cameras.any((it) => it.lensDirection == CameraLensDirection.back)) {
      setState(() {
        permissionState.value = PermissionsState.noCamera;
        _cameraInitialized = false;
      });
      return;
    }

    controller = CameraController(
      cameras.firstWhere((it) => it.lensDirection == CameraLensDirection.back),
      ResolutionPreset.max,
    );

    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _cameraInitialized = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        setState(() {
          switch (e.code) {
            case 'CameraAccessDenied':
              print("Camera access denied.");
              permissionState.value = PermissionsState.cameraDenied;
              break;
            default:
              print("Error occurred.");
              permissionState.value = PermissionsState.noCamera;
              break;
          }
          _cameraInitialized = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    lifecycleListener.dispose();
    super.dispose();
  }
}

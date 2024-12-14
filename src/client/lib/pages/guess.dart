import 'dart:async';
import 'package:camera/camera.dart';
import 'package:direction_guesser/widgets/missing_device_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holding_gesture/holding_gesture.dart';
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
  cameraUnavailable,
  gpsServicesUnavailable,
  cameraDenied,
  locationDenied,
  bothDenied
}

class _GuessPageState extends State<GuessPage> with TickerProviderStateMixin {
  // set up a notifier for the permissions state
  ValueNotifier<PermissionsState> permissionState =
      ValueNotifier(PermissionsState.okay);
  late AppLifecycleListener lifecycleListener;
  late CameraController controller;
  late AnimationController animationController;
  double latitude = 0.0;
  double longitude = 0.0;
  List<double> headings = [];
  bool collectingHeadings = false;
  bool tryAgain = false;
  double targetLatitude = 0.0;
  double targetLongitude = 0.0;
  bool newGame = true;
  List<Map<String, dynamic>> cities = [];
  String targetCity = "";

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: true);

    super.initState();
    // create a listener for lifecycle state changes
    // we only need to check onRestart (rather than onShow and onResume) because
    // the app is force restarted by the OS when permissions are changed
    lifecycleListener = AppLifecycleListener(onRestart: checkSensors);

    // check permissions on start
    checkSensors();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: ValueListenableBuilder<PermissionsState>(
                valueListenable: permissionState,
                builder: (_, PermissionsState permissions, child) {
                  if (permissions == PermissionsState.gpsServicesUnavailable) {
                    return MissingDeviceCard(
                        mainText:
                            "Your device is missing either GPS or a compass.",
                        subText: "Without these, you are unable to play.");
                  } else if (permissions ==
                      PermissionsState.cameraUnavailable) {
                    return MissingDeviceCard(
                        mainText: "Your device is missing a suitable camera.",
                        subText: "Without this, you are unable to play.");
                  } else if (permissions == PermissionsState.cameraDenied) {
                    return needCameraUI();
                  } else if (permissions == PermissionsState.locationDenied ||
                      permissions == PermissionsState.bothDenied) {
                    return needLocationsUI();
                  } else {
                    return guessUI();
                  }
                })));
  }

  Container guessUI() {
    TextStyle largeStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.titleLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        color: Theme.of(context).colorScheme.onSurface);

    TextStyle mediumStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.titleLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
        color: Theme.of(context).colorScheme.onSurface);

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
                child: Column(mainAxisSize: MainAxisSize.max, children: [
              Spacer(),
              Text("Point to...", style: largeStyle),
              Text(targetCity,
                  style: TextStyle(
                      fontStyle:
                          Theme.of(context).textTheme.displayMedium?.fontStyle,
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.error)),
              Spacer(),
              Text(
                "Line up your guess using\nthe camera as a guide.",
                style: mediumStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              SizedBox(height: 16),
              HoldTimeoutDetector(
                  onTimeout: () {
                    collectingHeadings = false;
                    if (tryAgain) {
                      tryAgain = false;
                    } else {
                      submitGuess(context, targetCity);
                    }
                  },
                  onTimerInitiated: () {
                    animationController.value = 0;
                    animationController.forward();
                    collectingHeadings = true;
                    tryAgain = false;
                    collectHeadings(context);
                  },
                  onCancel: () {
                    collectingHeadings = false;
                    animationController.value = 0;
                  },
                  holdTimeout: Duration(milliseconds: 3000),
                  child: collectingHeadings
                      ? Center(
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
                                            color: Colors.red, thickness: 2))),
                                Positioned.fill(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: CircularProgressIndicator(
                                              value: animationController.value,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                              strokeWidth: 8.0,
                                            ))))
                              ])))
                      : Center(
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
                                            color: Colors.red, thickness: 2))),
                              ])))),
              SizedBox(height: 16),
              Text(
                "Press and hold to submit your guess!",
                style: mediumStyle,
                textAlign: TextAlign.center,
              ),
              Spacer()
            ]))));
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

  Container needCameraUI() {
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
  }

  Future<void> collectHeadings(BuildContext context) async {
    // clear any headings from a previous unfinished guess
    headings.clear();

    // get the latitude and longitude
    var location = await Geolocator.getCurrentPosition();

    // while the user is holding down, continuously collect headings
    while (collectingHeadings) {
      var direction = await FlutterCompass.events?.first;
      setState(() {
        latitude = location.latitude;
        longitude = location.longitude;
        headings.add((direction?.heading)!);
      });
      if (headings.any((it) {
            return (it - direction!.heading!).abs() > 20;
          }) &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text('Hold still!',
                    style: TextStyle(
                        fontStyle:
                            Theme.of(context).textTheme.titleMedium?.fontStyle,
                        fontSize:
                            Theme.of(context).textTheme.titleMedium?.fontSize,
                        color: Theme.of(context).colorScheme.onPrimary))),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        collectingHeadings = false;
        tryAgain = true;
      }
    }
  }

  Future<void> submitGuess(BuildContext context, String city) async {
    // TODO: for now doing this here since not compiling backend and the GameServices causes an error
    // but it should go in the if (guessSentSuccessfully) {}
    // navigate to the score page

    //Navigator.pushNamed(context, '/score', arguments: city);

    final prefs = await SharedPreferences.getInstance();
    bool guessSentSuccessfully = false;
    if (context.mounted) {
      if(roomState.value == RoomState.owner || roomState.value == RoomState.joiner) {
        guessSentSuccessfully = await context.read<GameServices>().lobbySubmitGuess(
            headings,
            latitude,
            longitude,
            targetLatitude,
            targetLongitude
        );
      } else {
      guessSentSuccessfully = await context.read<GameServices>().sendGuess(
          headings,
          latitude,
          longitude,
          targetLatitude,
          targetLongitude
          );
      }
    }

    // Check the result of sending the guess
    if (guessSentSuccessfully) {
      // Show success message
      Navigator.pushNamed(context, '/score', arguments: city);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guess successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guess unsuccessful!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void checkSensors() async {
    // if something is not available on this device, don't bother checking permissions
    if (permissionState.value == PermissionsState.cameraUnavailable ||
        permissionState.value == PermissionsState.gpsServicesUnavailable) {
      return;
    }

    // check if there is a suitable back-facing camera
    if (!cameras.any((it) => it.lensDirection == CameraLensDirection.back)) {
      setState(() {
        permissionState.value = PermissionsState.cameraUnavailable;
      });
      return;
    }

    // initialize the controller to the first rear-facing camera
    controller = CameraController(
      cameras.firstWhere((it) => it.lensDirection == CameraLensDirection.back),
      ResolutionPreset.max,
    );

    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        setState(() {
          switch (e.code) {
            case 'CameraAccessDenied':
              if (permissionState.value == PermissionsState.okay) {
                permissionState.value = PermissionsState.cameraDenied;
                return;
              } else if (permissionState.value ==
                  PermissionsState.locationDenied) {
                permissionState.value = PermissionsState.bothDenied;
                return;
              }
              break;
            default:
              // permissions were allowed but something else caused an error,
              // assume the camera is inaccessible
              permissionState.value = PermissionsState.cameraUnavailable;
              return;
          }
        });
      }
    });

    // now, check location services
    await Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (permissionState.value == PermissionsState.okay) {
          permissionState.value = PermissionsState.locationDenied;
          return;
        } else if (permissionState.value == PermissionsState.cameraDenied) {
          permissionState.value = PermissionsState.bothDenied;
          return;
        }
        return;
      } else if (permission == LocationPermission.unableToDetermine) {
        permissionState.value = PermissionsState.gpsServicesUnavailable;
        return;
      }

      // made it through every check, permissions are good
      permissionState.value = PermissionsState.okay;
    });

    //Get the list of cities
    if (newGame) {
      var location = await Geolocator.getCurrentPosition();
      //String city = await context.read<GameServices>().randomCity(location.latitude, location.longitude);
      cities = await context.read<GameServices>().getRandomCities(location.latitude.toStringAsFixed(2), location.longitude.toStringAsFixed(2), 5);
      newGame = false;
      if (cities.isEmpty) {
        permissionState.value = PermissionsState.gpsServicesUnavailable;
        return;
      }
    }
    targetCity = cities[0]['name'];
    targetLatitude = cities[0]['latitude'];
    targetLongitude = cities[0]['longitude'];
    cities.removeAt(0);
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    lifecycleListener.dispose();
    super.dispose();
  }
}

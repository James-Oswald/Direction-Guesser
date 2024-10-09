import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

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
  String position = "No position.";
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
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFFFAF8FF)
                                : Color(0xFF121318),
                            Theme.of(context).brightness == Brightness.light
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
                    onPressed: onGetPositionTapped,
                    child: Text("Get Position")),
                ElevatedButton(
                    onPressed: onGetHeadingTapped, child: Text('Get Heading')),
                Text("Current position: $position\nCurrent heading: $heading",
                    style: TextStyle(fontSize: 12)),
                Spacer()
              ]);
            }
          });
    }
  }

  Future<void> onGetPositionTapped() async {
    var location = await Geolocator.getCurrentPosition();
    setState(() {
      position = location.toString();
    });
  }

  Future<void> onGetHeadingTapped() async {
    var direction = await FlutterCompass.events?.first;
    setState(() {
      heading = (direction?.heading)!;
    });
  }

  Future<LocationPermission> getLocationPermissions() async {
    return await Geolocator.checkPermission();
  }
}

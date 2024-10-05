import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../main.dart';

class CameraTestPage extends StatefulWidget {
  const CameraTestPage({super.key});

  @override
  State<CameraTestPage> createState() => _CameraTestPageState();
}

class _CameraTestPageState extends State<CameraTestPage> {
  late CameraController controller;
  ValueNotifier<String> position = ValueNotifier("No position.");

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
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    } else {
      return Column(children: [
        Stack(children: [
          Center(child: CameraPreview(controller)),
          // Use a row to center the vertical divider in the center of the
          // screen regardless of screen dimensions
          Row(children: const [
            Spacer(),
            VerticalDivider(color: Colors.red, thickness: 2),
            Spacer()
          ])
        ]),
        FilledButton(
            onPressed: onGetPositionTapped, child: Text("Get Position")),
        ValueListenableBuilder<String>(
          valueListenable: position,
          builder: (BuildContext context, String value, child) {
            return Text("Current position: $value",
                style: TextStyle(fontSize: 12));
          },
        ),
      ]);
    }
  }

  Future<void> onGetPositionTapped() async {
    var location = await Geolocator.getCurrentPosition();
    setState(() {
      position = ValueNotifier(location.toString());
    });
    print(position);
  }
}

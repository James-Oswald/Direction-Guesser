import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CameraTestPage extends StatefulWidget {
  const CameraTestPage({super.key});

  @override
  State<CameraTestPage> createState() => _CameraTestPageState();
}

class _CameraTestPageState extends State<CameraTestPage> {
  late CameraController controller;

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
      return Stack(children: [
        Center(child: CameraPreview(controller)),
        // Use a row to center the vertical divider in the center of the
        // screen regardless of screen dimensions
        Row(children: const [
          Spacer(),
          VerticalDivider(color: Colors.red, thickness: 2),
          Spacer()
        ])
      ]);
    }
  }
}

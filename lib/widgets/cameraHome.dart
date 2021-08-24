import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import '../services/camera.dart';
import 'bndbox.dart';
import '../services/models.dart';

class CameraHomePage extends StatefulWidget {
  // final List<CameraDescription>? cameras;

  CameraHomePage();

  @override
  _CameraHomePageState createState() => new _CameraHomePageState();
}

class _CameraHomePageState extends State<CameraHomePage> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    loadCameras();
  }

  /// load cameras once the widget has loaded
  void loadCameras() async {
    cameras = await availableCameras();
  }

  loadModel() async {
    String? res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolo.tflite",
          labels: "assets/labels.txt",
        );
        break;

      case resnet:
        res = await Tflite.loadModel(
            model: "assets/resnet.tflite",
            labels: "assets/labels.txt");
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/resnet.tflite",
            labels: "assets/labels.txt");
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      // HAMISH: this works with a ternary statement to decide whether to show the buttons or not
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text(yolo),
                    onPressed: () => onSelect(yolo),
                  ),
                  ElevatedButton(
                    child: const Text(resnet),
                    onPressed: () => onSelect(resnet),
                  ),
                ],
              ),
            )
          // HAMISH: this is where the actual camera is displayed
          : Stack(
              children: [
                Camera(
                  cameras,
                  _model,
                  setRecognitions,
                ),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model),
              ],
            ),
    );
  }
}

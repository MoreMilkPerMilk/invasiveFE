import 'dart:collection';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tflite/tflite.dart';
import 'package:tuple/tuple.dart';

import 'models.dart';

const int MAX_LOOK_BACK_SIZE = 5;
const double MIN_CONFIDENCE_VAL = 0.90;

// HAMISH: current idea -- take a photo of the last frame, display it as
// the background widget, and then have an overlay.

typedef void Callback(List<dynamic>? list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final Callback setRecognitions;
  final String model;


  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;
  bool _cameraOn = true;
  PanelController _pc = new PanelController();
  String foundSpecies = "None";

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  void startCamera() {
    ListQueue<Tuple2<String, double>> seenBuffer = new ListQueue();
    if (widget.cameras == null || widget.cameras!.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras![0],
        ResolutionPreset.high,
      );
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        // _pc.close();
        controller!.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

            if (widget.model == resnet) {

              // Resize image to 224 x 224
              var imgAsBytes = img.planes.map((plane) {
                return plane.bytes;
              }).toList();
              //var decodedImg = decodeImage(new List.from(imgAsBytes));
              //var resizedImg = copyResize(decodedImg, width: 224, height: 224);
              // WE NEED TO SAVE THE IMAGE TEMPORARILY TO DO THIS... STUPID FLUTTER!!!
              Tflite.runModelOnFrame(
                bytesList: imgAsBytes,
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                print("Detection took ${endTime - startTime}");
                print(recognitions);
                if (recognitions!.isNotEmpty && thresholdDetection(recognitions, seenBuffer)) {
                  print(">>>>>>>>>>>>>>>>>>>>>>> THRESHOLD REACHED");
                  // HAMISH: todo -- now load slide over widget for detection
                  HapticFeedback.heavyImpact();
                  Tflite.close();
                  _pc.open();
                  //
                  setState(() {
                    _cameraOn = false;
                  });
                  return; // stop Tflite recognition!
                }

                widget.setRecognitions(recognitions, img.height, img.width);
                isDetecting = false;
              });
            }
              else { // yolo
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: widget.model == yolo ? 0 : 127.5,
                imageStd: widget.model == yolo ? 255.0 : 127.5,
                numResultsPerClass: 1,
                threshold: widget.model == yolo ? 0.2 : 0.4,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions, img.height, img.width);

                isDetecting = false;
              });
            }
          }
        });
      });
    }
  }

  bool thresholdDetection(List<dynamic> recognitions, ListQueue<Tuple2<String, double>> seenBuffer) {
    String label = recognitions[0]["label"];  // assume greatest confidence is first presented
    double conf = recognitions[0]["confidence"];
    seenBuffer.add(Tuple2<String, double>(label, conf));
    if (seenBuffer.length > MAX_LOOK_BACK_SIZE) {
      // remove the oldest element of the queue
      seenBuffer.removeFirst();
    }

    bool aboveThreshold = seenBuffer.every((element) => element.item2 >= MIN_CONFIDENCE_VAL);
    Set<String> setBuffer = seenBuffer.map((element) => element.item1).toSet(); // get all recognitions
    bool sameElement = setBuffer.length == 1;
    bool notNegative = setBuffer.every((element) => element != "Negatives");
    bool minFrames = seenBuffer.length == MAX_LOOK_BACK_SIZE;
    print(seenBuffer);
    print(setBuffer);
    print("thresh: $aboveThreshold, same: $sameElement");
    if (aboveThreshold && sameElement && notNegative && minFrames) {
      foundSpecies = setBuffer.first;
      return true;
    } else {
      foundSpecies = "None";
      return false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    // FIXME: HAMISH: removed max height and width of OVERFLOW BOX -- fixes issues with sliding panel
    // seems to work on mine, please test
    return Container(
      // maxHeight:
      //     screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      // maxWidth:
      //     screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: SlidingUpPanel(
        backdropEnabled: true,
        controller: _pc,
        minHeight: 0,
        // isDraggable: true,
        panel: OverlayPanel(foundSpecies, _pc),
        body: _cameraOn ? CameraPreview(controller!) : Center(child: Text("CAMERA IMAGE HERE")),
        borderRadius: radius,
        onPanelClosed: () {
          setState(() {
            _cameraOn = true;
          });
        },
      ),
    );
  }
}

class OverlayPanel extends StatelessWidget {
  OverlayPanel(this.foundSpecies, this._pc);

  final String foundSpecies;
  final PanelController _pc;

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(
            children: [
              Text("$foundSpecies"),
              // ElevatedButton(onPressed: () {
              //   print("Hello!");
                // _pc.close();
              // }, child: Text("close window"))
            ],
          ),
    );
  }
}

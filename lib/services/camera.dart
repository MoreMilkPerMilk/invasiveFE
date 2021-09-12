import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:image/image.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/services/gpsService.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:invasive_fe/services/imgConversionService.dart';
import 'package:invasive_fe/widgets/panel.dart';
import 'package:objectid/objectid.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tflite/tflite.dart';
import 'package:tuple/tuple.dart';

import 'models.dart';

const int MAX_LOOK_BACK_SIZE = 5;
const double MIN_CONFIDENCE_VAL = 0.90;
XFile photo = new XFile.fromData(new Uint8List(1));

const int MAX_LOOK_BACK_TIME = 3000;

enum Status {
  negativeNormal, // negative recognition
  negativeThreshold, // negative recognition X seconds in a row
  detected, // detected a invasive species
}

enum Detection {
  negative, // negative recognition
  positive, // negative recognition X seconds in a row
}

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
  int _numResults = 2;
  PanelController _pc = new PanelController();
  String foundSpecies = "None";

  @override
  void initState() {
    super.initState();
    startCamera();
  }

  void startCamera() {
    ListQueue<Tuple2<String, double>> seenBuffer = new ListQueue();
    ListQueue<int> timeBuffer = new ListQueue();
    print(widget.cameras);
    if (widget.cameras == null || widget.cameras!.length < 1) {
      print('No camera is found');
    } else {

      // resolution lowered for android devices
      var cameraRes = ResolutionPreset.high;
      if (Platform.isAndroid) {
        cameraRes = ResolutionPreset.medium;
      }
      controller = new CameraController(
        widget.cameras![0],
        cameraRes,
      );

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller!.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            int startTime = new DateTime.now().millisecondsSinceEpoch;
            if (widget.model == resnet) {
              runResnetOnFrame(img, startTime, seenBuffer, timeBuffer);
            } else {
              runYoloOnFrame(img, startTime);
            }
          }
        });
      });
    }
  }

  void runResnetOnFrame(CameraImage img, int startTime, ListQueue<Tuple2<String, double>> seenBuffer) async {

    // convert camera img to bytes
    List<Uint8List> imgAsBytes = img.planes.map((plane) {
      return plane.bytes;
    }).toList();

    var recognitions = await Tflite.runModelOnFrame(
      bytesList: imgAsBytes,
      imageHeight: img.height,
      imageWidth: img.width,
      numResults: _numResults,
    );

    int endTime = new DateTime.now().millisecondsSinceEpoch;
    // print("Detection took ${endTime - startTime}");
    // print(recognitions);
    if (!_cameraOn) {
      seenBuffer.clear();
    }

    if (recognitions!.isNotEmpty && _cameraOn) {
      switch (thresholdDetection(recognitions, seenBuffer, timeBuffer)) {
        case Status.negativeNormal:
          // do nothing :)
          break;
        case Status.negativeThreshold:
          // show toast!
          Fluttertoast.showToast(
              msg: "Hold the camera 30 cm away from the plant",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black12,
              textColor: Colors.white,
              fontSize: 20.0
          );
          break;
        case Status.detected:
			// if android we directly convert yuv420 to png (workaround for takePicture())
		      if (Platform.isAndroid) {
		
		        // convert yuv420 to png
		        convertYUV420toImageColor(img).then((png_img) {
		          XFile photo = XFile.fromData(png_img!.getBytes());
		          // show the slide over widget
		          _pc.open();
		          HapticFeedback.heavyImpact();
		        });
		      } else {

          // show the slide over widget
		  controller!.takePicture().then((value) {
        // photo = value;
        setState(() {
          photo = value;
          // show the slide over widget
          _pc.open();
          HapticFeedback.heavyImpact();
        });
        print(photo.name);
        _pc.open();
        HapticFeedback.heavyImpact();
      });


          setState(() {
            _cameraOn = false;
            _numResults = 0;
          });
          break;
      }
    }

    widget.setRecognitions(recognitions, img.height, img.width);
    isDetecting = false;
  }

  void runYoloOnFrame(CameraImage img, int startTime) {
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

  Status thresholdDetection(List<dynamic> recognitions, ListQueue<Tuple2<String, double>> seenBuffer,
      ListQueue<int> timeBuffer) {
    String label = recognitions[0]["label"]; // assume greatest confidence is first presented
    double conf = recognitions[0]["confidence"];

    seenBuffer.add(Tuple2<String, double>(label, conf));
    if (seenBuffer.length > MAX_LOOK_BACK_SIZE) {
      // remove the oldest element of the queue
      seenBuffer.removeFirst();
    }

    int currentTime = new DateTime.now().millisecondsSinceEpoch;
    timeBuffer.add(currentTime);
    if (currentTime - timeBuffer.first >= MAX_LOOK_BACK_TIME) {
      timeBuffer.removeFirst();
    }

    bool aboveThreshold = seenBuffer.every((element) => element.item2 >= MIN_CONFIDENCE_VAL);
    Set<String> setBuffer = seenBuffer.map((element) => element.item1).toSet(); // get all recognitions
    bool sameElement = setBuffer.length == 1;
    bool notNegative = setBuffer.every((element) => element != "Negatives");
    bool minFrames = seenBuffer.length == MAX_LOOK_BACK_SIZE;
    // print(seenBuffer);
    // print(setBuffer);
    // print("thresh: $aboveThreshold, same: $sameElement");
    if (aboveThreshold && sameElement && notNegative && minFrames) {
      timeBuffer.clear();
      foundSpecies = setBuffer.first;
      return Status.detected;
    } else {
      foundSpecies = "None";
      return Status.negativeNormal;
    }
  }

  @override
  void dispose() {
    Fluttertoast.cancel(); // hide all toasts
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

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    var camera = controller!.value;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    print("rebuilding with species: $foundSpecies");

    return Container(
      child: SlidingUpPanel(
        backdropEnabled: true,
        controller: _pc,
        minHeight: 0,
        panel: Panel(foundSpecies, photo, _pc),
        body: Transform.scale( // HAMISH: Fixed the weird scaling issues!
          scale: scale,
          child: Center(
            child: Stack(children: [
              CameraPreview(controller!),
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Align(
                      child: ColorFiltered(
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          child: Image(image: AssetImage('assets/frame.png'), width: 250, height: 250)
                      )
                  )
              ),
            ]),
          ),
        ),
        borderRadius: radius,
        onPanelClosed: () {
          controller!.startImageStream((image) => null);
          setState(() {
            _cameraOn = true;
            _numResults = 2;
            // photo = new XFile.fromData(new Uint8List(1));
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invasive_fe/services/classifier.dart';
import 'package:invasive_fe/services/classifier_float.dart';
import 'package:invasive_fe/services/classifier_scraped.dart';
import 'package:invasive_fe/widgets/panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:image/image.dart' as img;

import '../services/camera.dart';
import 'bndbox.dart';
import '../services/models.dart';

enum Status {
  negativeNormal, // negative recognition
  negativeThreshold, // negative recognition X seconds in a row
  detected, // detected a invasive species
}

enum Detection {
  negative, // negative recognition
  positive, // negative recognition X seconds in a row
}

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

  XFile _image = new XFile("");
  String path = "";
  String label = "";
  String foundSpecies = "";
  PanelController _pc = new PanelController();
  Status status = Status.negativeNormal;
  File photo = File("");

  List<CameraDescription>? cameras;
  late Future loaded;

  final Classifier deepWeedsClassifier = ScrapedWeedClassifier();

  @override
  void initState() {
    super.initState();
    // loadCameras();
    // Future cameraFuture = availableCameras();
    // cameraFuture.then((value) => cameras = value);
    // onSelect(resnet);
    // loaded = Future.wait([cameraFuture]);
  }

  Future getImagefromCamera() async {
    var picker = new ImagePicker();

    var image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      print("image path = " + image!.path);
      _image = image;
      path = image.path;
      photo = File(path);

      img.Image imageInput = img.decodeImage(File(path).readAsBytesSync())!;
      var pred = deepWeedsClassifier.predict(imageInput);
      label = pred.label + " " + pred.score.toString();
      foundSpecies = pred.label;
      print("PREDICTION-----S");
      print(pred);
      print("PREDICTION-----E");
      _pc.open();
      HapticFeedback.heavyImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    // getImagefromCamera();
    if (label == "") {
      getImagefromCamera();
    }
    // return Scaffold(
    //   // HAMISH: this works with a ternary statement to decide whether to show the buttons or not
    //   body: FutureBuilder(
    //     future: loaded,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         return Stack(
    //           children: [
    //             Camera(
    //               cameras,
    //               _model,
    //               setRecognitions,
    //             ),
    //             BndBox(
    //                 _recognitions == null ? [] : _recognitions,
    //                 math.max(_imageHeight, _imageWidth),
    //                 math.min(_imageHeight, _imageWidth),
    //                 screen.height,
    //                 screen.width,
    //                 _model),
    //           ],
    //         );
    //       } else {
    //         return Align(child: Text("Loading ..."), alignment: Alignment.center);
    //       }
    //     },
    //   ),
    // );
    // return Scaffold(
    //     body: GestureDetector(
    //   onTap: getImagefromCamera,
    //   child: path == ""
    //       ? Container(
    //           decoration: BoxDecoration(
    //               color: Colors.red,
    //               border: Border.all(color: Colors.red, width: 1.0),
    //               borderRadius: BorderRadius.circular(10.0)),
    //           child: Column(
    //             children: <Widget>[
    //               SizedBox(height: 30.0),
    //               Icon(Icons.camera_alt, color: Colors.red),
    //               SizedBox(height: 10.0),
    //               Text('Take Image of the Item',
    //                   style: TextStyle(color: Colors.red)),
    //               SizedBox(height: 30.0)
    //             ],
    //           ))
    //       // : Image.file(File(path)),
    //       : Container(
    //       child: Column(
    //         children: [
    //           SizedBox(height:100),
    //           Text("You found " + label),
    //         ],
    //       )
    //   )
    // ));

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
        body: GestureDetector(
            onTap: getImagefromCamera,
            child: Container(
              child: SlidingUpPanel(
                backdropEnabled: true,
                controller: _pc,
                minHeight: 0,
                // maxHeight: foundSpecies != "Negatives" ? 500 : 300,
                maxHeight: 500,
                // panel: Panel(foundSpecies, photo, _pc, foundSpecies
                // == "Negatives"),
                panel: Panel(foundSpecies, photo, _pc, false),
                body: Center(
                    child: Stack(children: [
                      Text(label)
                      // CameraPreview(controller!),
                      // Container(
                      //     width: double.infinity,
                      //     height: double.infinity,
                          // child: Align(
                          //     child: ColorFiltered(
                          //         colorFilter: ColorFilter.mode(
                          //             Colors.black.withOpacity(0.2),
                          //             BlendMode.dstATop),
                          //         child: Image(
                          //             image: AssetImage('),
                          //             width: 250,
                          //             height: 250)))),
                    ]),
                  ),
                borderRadius: radius,
                // onPanelClosed: () {
                //   Fluttertoast.cancel(); // hide all toasts
                //   repeatedNegativeCount = 0;
                //   repeatedNegative = false;
                //   startTfliteDetection();
                // },
              ),
            )));
  }
}

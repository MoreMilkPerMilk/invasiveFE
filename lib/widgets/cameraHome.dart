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
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Scaffold(
        body: GestureDetector(
            // onTap: getImagefromCamera,,
            child: Container(
              // color: ,
              child: SlidingUpPanel(
                backdropEnabled: true,
                controller: _pc,
                minHeight: 0,
                // maxHeight: foundSpecies != "Negatives" ? 500 : 300,
                maxHeight: 500,
                // panel: Panel(foundSpecies, photo, _pc, foundSpecies
                // == "Negatives"),
                panel: Panel(foundSpecies, photo, _pc, false),
                body: SafeArea(
                  minimum: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      //title
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                              'Classify',
                              style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Open the camera to classify an invasive species.')
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: OutlinedButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.green,
                                // shape:
                              ),
                              onPressed: () {
                                _pc.close();
                                getImagefromCamera();
                              },
                              icon: Icon(Icons.camera_alt_outlined, size: 18),
                              label: Text("Open Camera"),
                            )
                        )
                      ),
                      if (path != "")
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.file(
                                  File(path),
                                  width: 300,
                                ),
                                Text(label)
                              ],
                            )
                        )
                      else
                        Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image(
                            image: AssetImage('assets/capture_example.gif'),
                            width: 300,
                            height: 300)
                        )
                    ],
                  )
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

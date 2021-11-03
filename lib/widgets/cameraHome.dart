import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invasive_fe/services/classifier.dart';
import 'package:invasive_fe/services/classifier_float.dart';
import 'package:invasive_fe/services/classifier_scraped.dart';
import 'package:invasive_fe/widgets/panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:image/image.dart' as img;

import 'bndbox.dart';
import '../services/models.dart';

double THRESHOLD = 0.4;

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
  bool goodDetection = false;

  List<CameraDescription>? cameras;
  late Future loaded;

  final Classifier deepWeedsClassifier = ScrapedWeedClassifier();

  @override
  void initState() {
    super.initState();
    //wait on nothing by default
    loaded = Future.wait([]);
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
      label = pred.label.toTitleCase()! + " " + pred.score.toStringAsFixed(3);

      goodDetection = false;
      if (pred.score > THRESHOLD) {
        foundSpecies = pred.label.toTitleCase()!;
        goodDetection = true;
      }
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

    //76,174,80
    return Scaffold(
        body: FutureBuilder(
            future: loaded,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  color: Color.fromRGBO(76, 174, 80, 1),
                  child: SlidingUpPanel(
                    backdropEnabled: true,
                    controller: _pc,
                    minHeight: 0,
                    // maxHeight: foundSpecies != "Negatives" ? 500 : 300,
                    maxHeight: !goodDetection ? 300 : 500,
                    // panel: Panel(foundSpecies, photo, _pc, foundSpecies
                    // == "Negatives"),
                    panel: Panel(foundSpecies, photo, _pc, !goodDetection),
                    body: (snapshot.connectionState == ConnectionState.done) ? SafeArea(
                        minimum: const EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
                            Container(
                              // color: Colors.green,
                              // margin: const EdgeInsets.all(0),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text('Classify',
                                          style: TextStyle(
                                              fontSize: 25,
                                              // color: Color.fromRGBO(76, 174, 80, 1),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold))),
                                  Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                          'Open the camera to classify an invasive species.',
                                      style: TextStyle(color: Colors.white),)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                //217, 222, 175
                                //238, 240, 221
                                // color: Color.fromRGBO(218, 222, 182, 1),
                                color: Color.fromRGBO(238, 240, 221, 1.0),
                              margin: const EdgeInsets.only(bottom: 0),
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [

                                    Card(
                                      //151, 199, 247
                                      color: Color.fromRGBO(74, 95, 145, 1),
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20,
                                                  bottom: 20,
                                                  left: 50,
                                                  right: 50),
                                              // child: Image(
                                              //     image: path == "" ? AssetImage('assets/capture_example.gif') : File(path),
                                              //     width: 300,
                                              //     height: 300)
                                              child: (path == "")
                                                  ? Image(
                                                      image: AssetImage(
                                                          'assets/capture_example.gif'),
                                                      width: 250,
                                                      height: 250)
                                                  : Image.file(
                                                      File(path),
                                                      width: 200,
                                                    )),
                                          Padding(
                                              padding: const EdgeInsets.only(bottom:5, left:15, right:15),
                                              child: Text(
                                                  (path == "") ? "Try and frame the plants flowers or leaves as the subject of the capture. " : label,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                              textAlign: TextAlign.center,)),
                                          if (!goodDetection && path != "")
                                            Card(
                                              color: Color.fromRGBO(220, 220, 220, 1),
                                              margin: const EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Text("The model wasn't confident it detected an invasive species. You can manually report it if you are sure "
                                                        "the captured species is a weed.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black))
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: OutlinedButton.icon(
                                                      style: TextButton.styleFrom(
                                                        primary: Colors.red,
                                                        backgroundColor: Colors.white,
                                                        // shape:
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          // widget.buttonColor = Colors.grey;

                                                        });
                                                      },
                                                      icon: Icon(Icons.send, size: 18),
                                                      label: Text("REPORT"),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: OutlinedButton.icon(
                                              style: TextButton.styleFrom(
                                                primary: Colors.green,
                                                backgroundColor: Colors.white,
                                                // shape:
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _pc.close();
                                                  loaded = getImagefromCamera();
                                                });
                                                // getImagefromCamera();
                                              },
                                              icon: Icon(
                                                  Icons.camera_alt_outlined,
                                                  size: 18),
                                              label: Text("CAPTURE"),
                                            ))),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )) :
                    Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()),
                    borderRadius: radius,
                    // onPanelClosed: () {
                    //   Fluttertoast.cancel(); // hide all toasts
                    //   repeatedNegativeCount = 0;
                    //   repeatedNegative = false;
                    //   startTfliteDetection();
                    // },
                  ),
                );
              // } else {
              //   // the futures have not yet completed; display a loading page
              //   return Container(
              //     // color: ,
              //     child: SlidingUpPanel(
              //       backdropEnabled: true,
              //       controller: _pc,
              //       minHeight: 0,
              //       // maxHeight: foundSpecies != "Negatives" ? 500 : 300,
              //       maxHeight: !goodDetection ? 300 : 500,
              //       // panel: Panel(foundSpecies, photo, _pc, foundSpecies
              //       // == "Negatives"),
              //       panel: Panel(foundSpecies, photo, _pc, !goodDetection),
              //       body: Align(
              //           alignment: Alignment.center,
              //           child: CircularProgressIndicator()),
              //       borderRadius: radius,
              //     ),
              //   );
              // }
            }));

    return Scaffold(
        body: Container(
      // color: ,
      child: SlidingUpPanel(
        backdropEnabled: true,
        controller: _pc,
        minHeight: 0,
        // maxHeight: foundSpecies != "Negatives" ? 500 : 300,
        maxHeight: !goodDetection ? 300 : 500,
        // panel: Panel(foundSpecies, photo, _pc, foundSpecies
        // == "Negatives"),
        panel: Panel(foundSpecies, photo, _pc, !goodDetection),
        body: SafeArea(
            minimum: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                //title
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('Classify',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold))),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                        'Open the camera to classify an invasive species.')),
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
                        ))),
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
                      ))
                else
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image(
                          image: AssetImage('assets/capture_example.gif'),
                          width: 300,
                          height: 300))
              ],
            )),
        borderRadius: radius,
        // onPanelClosed: () {
        //   Fluttertoast.cancel(); // hide all toasts
        //   repeatedNegativeCount = 0;
        //   repeatedNegative = false;
        //   startTfliteDetection();
        // },
      ),
    ));
  }
}

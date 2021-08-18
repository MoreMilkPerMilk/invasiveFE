import 'dart:async';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class TfliteService {

  // _tensorflowService is a private member of class
  static final TfliteService _tensorflowService = TfliteService._internal();

  // factory constructor doesn't always create a new instance of its class
  factory TfliteService() {
    return _tensorflowService;
  }

  // privately referenced constructor
  TfliteService._internal();

  // asynchronous sequence of results through stream
  StreamController<List<dynamic>> _recognitionController = StreamController();
  Stream get recognitionStream => this._recognitionController.stream;

  bool _modelLoaded = false;

  /// asynchronous function to load tflite model into flutter
  Future<void> loadModel() async {
    try {
      this._recognitionController.add(null);
      await Tflite.loadModel(
        model: "assets/resnet.tflite",
        labels: "assets/labels.txt",
      );
      _modelLoaded = true;
    } catch (e) {
      print('error loading model');
      print(e);
    }
  }

  /// perform classification on input camera frame
  Future<void> runModel(CameraImage img) async {

    if (_modelLoaded) {

      // THIS WILL NEED TO BE MODIFIED TO CONVERT THE IMAGE
      // INTO A COMPATIBLE FORMAT (i.e. 224 * 224 stretched and cropped)
      // run model and return top results
      List<dynamic> recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        numResults: 3,
      );

      // shows recognitions on screen
      if (recognitions.isNotEmpty) {

        print(recognitions[0].toString());
        if (this._recognitionController.isClosed) {
          // restart if was closed
          this._recognitionController = StreamController();
        }
        // notify to listeners
        this._recognitionController.add(recognitions);
      }
    }
  }

  Future<void> stopRecognitions() async {
    if (!this._recognitionController.isClosed) {
      this._recognitionController.add(null);
      this._recognitionController.close();
    }
  }

  void dispose() async {
    this._recognitionController.close();
  }
}

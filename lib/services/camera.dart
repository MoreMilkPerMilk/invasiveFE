import 'package:camera/camera.dart';
import 'tflite.dart';

class CameraService {

  // _cameraService is a private member of class
  static final CameraService _cameraService = CameraService._internal();

  // factory constructor doesn't always create a new instance of its class
  factory CameraService() {
    return _cameraService;
  }

  // privately referenced constructor
  CameraService._internal();

  // instantiate tflite service in camera
  TfliteService _tfliteService = new TfliteService();

  //
  CameraController _cameraController;
  CameraController get cameraController => _cameraController;

  bool available = true;

  Future startService(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      cameraDescription,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    return _cameraController.initialize();
  }

  Future<void> startStreaming() async {

    _cameraController.startImageStream((img) async {
      try {
        if (available) {
          // Loads the model and recognizes frames
          available = false;
          await _tfliteService.runModel(img);
          await Future.delayed(Duration(seconds: 1));
          available = true;
        }
      } catch (e) {
        print('error running model with current frame');
        print(e);
      }
    });
  }
}
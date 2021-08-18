import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:invasive_fe/services/camera.dart';
import 'package:invasive_fe/services/tflite.dart';
import 'package:invasive_fe/widgets/recognition_panel.dart';


// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {

  // Initiate services
  TfliteService _tfliteService = TfliteService();
  CameraService _cameraService = CameraService();

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;



  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    // Perform setup of camera and tflite recognising frames
    setUp();
  }

  Future setUp() async {
    if (!mounted) {
      return;
    }
    if (_initializeControllerFuture == null) {
      _initializeControllerFuture = _cameraService.startService(widget.camera).then((value) async {
        await _tfliteService.loadModel();
        startRecognitions();
      });
    } else {
      await _tfliteService.loadModel();
      startRecognitions();
    }
  }

  startRecognitions() async {
    try {
      // starts the camera stream on every frame and then uses it to recognize the result every 1 second
      _cameraService.startStreaming();
    } catch (e) {
      print('error streaming camera image');
      print(e);
    }
  }

  stopRecognitions() async {
    // closes the streams
    await _cameraService.stopImageStream();
    await _tfliteService.stopRecognitions();
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    _tfliteService.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Looking for invasive species...')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            //return CameraPreview(_controller);
            return Stack(
              children: <Widget>[
                // shows the camera preview
                CameraPreview(_controller),
                // shows the recognition on the bottom
                Recognition(
                  ready: true,
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
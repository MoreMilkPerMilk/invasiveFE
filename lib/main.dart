import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/cameraHome.dart';

Future<void> main() async {

  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MyApp(
        // Pass the appropriate camera to the TakePictureScreen widget.
        cameras,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription>? cameras;

  MyApp(this.cameras);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvasiveFE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title: 'Invasive FE Home Page',
          cameras: this.cameras // pass in the cameras object for tflite use
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  MyHomePage({Key? key, required this.title, this.cameras}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () {
              print("moving to camera page");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CameraHomePage(widget.cameras))
              );
            }, child: Text("Camera Page")),
          ],
        ),
      ),
    );
  }
}

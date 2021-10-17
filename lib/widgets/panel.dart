import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:image/image.dart' as img;
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/gpsService.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:objectid/objectid.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Panel extends StatefulWidget {
  String foundSpecies;
  PanelController _pc;
  File photo;
  bool negative;

  Panel(this.foundSpecies, this.photo, this._pc, this.negative);

  @override
  _PanelState createState() {
    return new _PanelState();
  }
}

class _PanelState extends State<Panel> {

  bool _reportButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    // XFile testPhoto = XFile(widget.photoPath);
    // photo.readAsBytes().then((value){
    //   imgBytes = value;
    // });
    // Image img = Image.memory(imgBytes);
    if (widget.negative) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text("If you are trying to report an invasive plant, it is not being detected. Would you like to "
                  //     "report it manually?"),
                  Text.rich(
                    TextSpan(
                      text: "Cannot Detect Invasive Species!\n",
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                  Text.rich(TextSpan(
                    text: "If you are trying to report an invasive plant, it is not being detected. Would you like to "
                        "report it manually?",
                    style: TextStyle(fontSize: 15),
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.red,
                              ),
                              onPressed: () {
                                // Respond to button press
                                widget._pc.close();
                              },
                              icon: Icon(Icons.cancel_outlined, size: 18),
                              label: Text("CANCEL"),
                            )),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.green,
                              ),
                              onPressed: () {
                                // Respond to button press
                                // widget._pc.close();
                              },
                              icon: Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text("CONTINUE"),
                            )),
                      ),
                    ],
                  ),
                ],
              )));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                text: 'You Found: ',
                style: TextStyle(fontSize: 30),
                children: <TextSpan>[
                  TextSpan(text: '${widget.foundSpecies}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  height: 200,
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Image.file(
                        widget.photo,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Respond to button press
                              },
                              icon: Icon(Icons.my_library_add_rounded, size: 18),
                              label: Text("ADD DETAILS"),
                            )),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Respond to button press
                              },
                              icon: Icon(Icons.info_outline, size: 18),
                              label: Text("MORE INFO"),
                            )),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.red,
                              ),
                              onPressed: () {
                                // Respond to button press
                                widget._pc.close();
                              },
                              icon: Icon(Icons.cancel_schedule_send, size: 18),
                              label: Text("CANCEL"),
                            )),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton.icon(
                              style: TextButton.styleFrom(
                                primary: Colors.green,
                              ),
                              onPressed: () {
                                print("PRESSED DONE");
                                report(widget.foundSpecies, widget.photo);
                                widget._pc.close();

                              },
                              icon: Icon(Icons.done, size: 18),
                              label: Text("DONE"),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> report(String foundSpecies, File photo) async {
    setState(() {
      _reportButtonDisabled = true;
    });
    var pos = await determinePosition();
    sendReportToBackend(PhotoLocationData(pos, photo, foundSpecies));
  }
}

class PhotoLocationData{
  // Helper class to pass multiple parameters to compute
  final Position pos;
  final File photoImage;
  final String speciesName;
  PhotoLocationData(this.pos, this.photoImage, this.speciesName);
}

Future<void> sendReportToBackend(PhotoLocationData data) async {
  var photoLocation = new PhotoLocation(
    id: ObjectId(),
    // photo: data.photoImage,
    photo: data.photoImage,
    location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: data.pos.latitude, longitude: data.pos.longitude)),
    image_filename: 'placeholder.png',
  );

  // will need to check if report already exists
  Species species = await getSpeciesByName(data.speciesName);
  print(species);
  var report = new Report(
      id: ObjectId(),
      species_id: species.species_id,
      name: data.speciesName + DateTime.now().millisecondsSinceEpoch.toString(),
      status: 'open',
      photoLocations: [],
      notes: '',
      polygon: new GeoJsonMultiPolygon()
  );

  //in order, need the photoLocation after add to get the filename on server.
  photoLocation = await addPhotoLocation(photoLocation);
  await addReport(report);
  await addPhotoLocationToReport(report, photoLocation);
  Fluttertoast.showToast(
      msg: "Report Successfully Submitted",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
  // need to add report to user here too!
}

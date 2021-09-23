import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:image/image.dart' as img;
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/gpsService.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:objectid/objectid.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Panel extends StatefulWidget {
  String foundSpecies;
  PanelController _pc;
  XFile photo;

  Panel(this.foundSpecies, this.photo, this._pc) {
    print("init panel with name $foundSpecies");
  }

  @override
  _PanelState createState() {
    print("creating state with name $foundSpecies");
    // return new _PanelState(this.foundSpecies, this._pc, this.photo);
    return new _PanelState();
  }
}

class _PanelState extends State<Panel> {
  // _PanelState(this.foundSpecies, this._pc, this.photo);

  // String foundSpecies;
  // PanelController _pc;
  // XFile photo;

  bool _reportButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    print("building panel with name ${widget.foundSpecies}");
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
                        File(widget.photo.path),
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
                          )
                        ),
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
                            )
                        ),
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
                          )
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: OutlinedButton.icon(
                            style: TextButton.styleFrom(
                              primary: Colors.green,
                            ),
                            onPressed: () {
                              widget._pc.close();
                            },
                            icon: Icon(Icons.done, size: 18),
                            label: Text("DONE"),
                          )
                        ),
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

  Future<void> callback() async {
    setState(() {
      _reportButtonDisabled = true;
    });
    var pos = await determinePosition();
    compute(sendReportToBackend, PhotoLocationData(pos, photo, foundSpecies));
  }
}

class PhotoLocationData{
  // Helper class to pass multiple parameters to compute
  final Position pos;
  final XFile photoImage;
  final String speciesName;
  PhotoLocationData(this.pos, this.photoImage, this.speciesName);
}

Future<void> sendReportToBackend(PhotoLocationData data) async {

  var photoLocation = new PhotoLocation(
    id: ObjectId(),
    photo: data.photoImage,
    location: GeoPoint(latitude: data.pos.latitude, longitude: data.pos.longitude),
    weeds_present: [],
  );

  // add report to backend also
  // var report = new Report(
  //     report_id: report_id,
  //     species: species,
  //     name: name,
  //     status: status,
  //     photoLocations: photoLocations,
  //     notes: notes,
  //     polygon: polygon)

  //await addReport(report);
  await addPhotoLocation(photoLocation);
}

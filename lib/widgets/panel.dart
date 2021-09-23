import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:invasive_fe/models/Location.dart';
import 'package:invasive_fe/services/gpsService.dart';
import 'package:invasive_fe/services/httpService.dart';
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
    compute(reportLocationToBackend, pos);
  }
}

Future<void> reportLocationToBackend(Position pos) async {
  var location = new Location(
    id: ObjectId(),
    name: DateTime.now().toString(),
    lat: pos.latitude,
    long: pos.longitude,
    weeds_present: [],
  );
  await addLocation(location);
}

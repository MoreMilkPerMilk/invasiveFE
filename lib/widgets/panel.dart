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

  Panel(this.foundSpecies, this._pc);

  @override
  _PanelState createState() => _PanelState(this.foundSpecies, this._pc);
}

class _PanelState extends State<Panel> {
  _PanelState(this.foundSpecies, this._pc);

  String foundSpecies;
  PanelController _pc;

  bool _reportButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
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
                  TextSpan(text: '$foundSpecies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image(
                    image: NetworkImage(
                        'https://weeds.brisbane.qld.gov.au/sites/default/files/styles/large/public/images/lantana_camara17.jpg?itok=6FcRI2y7'),
                    width: 300,
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
                              // Respond to button press
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

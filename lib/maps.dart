import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers

const String MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucX'
    'RiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';


class MapsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Maps Page")),
        body: FlutterMap(
          options: MapOptions(
            center: LatLng(-27.4975, 153.0137),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
                urlTemplate: "http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                subdomains: ['a', 'b']
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(-27.4975, 153.0137),
                    builder: (context) =>
                        Container(
                            child: IconButton(
                              icon: Icon(
                                  Icons.location_pin,
                                  size: 40
                              ),
                              onPressed: () {
                                print('Marker pressed!');
                                var overlayState = Overlay.of(context);
                                var overlayEntry;
                                overlayEntry = OverlayEntry(
                                    builder: (context) =>
                                        Center(
                                            child: Material(
                                                child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          Text('weedy weed'),
                                                          IconButton(
                                                              onPressed: () {
                                                                overlayEntry
                                                                    .remove();
                                                              },
                                                              icon: Icon(
                                                                  Icons.close
                                                              ))
                                                        ]
                                                    )
                                                )
                                            )));
                                overlayState!.insert(overlayEntry);
                              },
                            )
                        )
                )
              ],
            ),
          ],
        )
    );
  }
}


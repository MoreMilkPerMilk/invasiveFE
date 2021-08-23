import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers


/// fixme; James's big bug bash board:
/// Clicking a marker multiple times generates multiple overlays.
/// Rotating the map rotates the icon.

/// todo; Features to develop:
/// Clustering markers.
/// Heat map with clickable regions (we'll have two views: cluster marker view
///   and heat map view).
/// Generating markers from a given file/object.
/// Nicer UI (overlays and markers).

const String MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucXRiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';


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
                generateMarker('weedy weed', LatLng(-27.4975, 153.0137)), // sample marker
                generateMarker('weedy wode', LatLng(-27.4916, 153.0136)) // sample marker
              ],
            ),
          ],
        )
    );
  }

  Marker generateMarker(String weedName, LatLng point) {
    return Marker(
            width: 40,
            height: 40,
            point: point,
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
                                                Text(weedName),
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
    );
  }
}




import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers

const String MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucX'
    'RiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';


class MapsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // initialise markers
    var markers = [
      Marker(
        width: 20,
        height: 20,
        point: LatLng(-27.4975, 153.0137),
        builder: (ctx) =>
            Container(
              child: IconButton(
                icon: Icon(
                  Icons.location_pin
                ),
                onPressed: pressMarker, // eventually we want to call this with some kind of markerInfo parameter, retrieved from the json file
              )
            )
      )
    ];

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
            markers: markers,
          ),
        ],
      )
    );
  }

  void pressMarker() {
    print('Marker pressed!');
  }
}


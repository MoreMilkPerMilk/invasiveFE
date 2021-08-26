import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

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
final PopupController _popupLayerController = PopupController();

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
          interactiveFlags: InteractiveFlag.all,
          onTap: (_) => _popupLayerController.hidePopup(),
        ),
        children: <Widget>[
          TileLayerWidget(
            options: TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: <String>['a', 'b', 'c'],
            ),
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              markers: generateMarkers(),
              popupController: _popupLayerController,
              popupBuilder: (_, Marker marker) {
                // this conditional is necessary since popupBuilder must take a Marker
                if (marker is WeedMarker) {
                  return WeedMarkerPopup(weed: marker.weed);
                }
                return Card(child: Text('Error: Not a weed.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  List<WeedMarker> generateMarkers() {
    return [
      WeedMarker(
        weed: Weed(
          name: 'Lantana',
          imagePath:
          'https://www.gardeningknowhow.com/wp-content/uploads/2020/11/pink-and-yellow-lantana-flowers-1024x768.jpg',
          lat: -27.4975,
          long: 153.0137,
        ),
      ),
    ];
  }
}


class Weed {
  static const double size = 40;

  Weed({
    required this.name,
    required this.imagePath,
    required this.lat,
    required this.long,
  });

  final String name;
  final String imagePath;
  final double lat;
  final double long;
}

class WeedMarker extends Marker {
  WeedMarker({required this.weed})
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.top),
    height: Weed.size,
    width: Weed.size,
    point: LatLng(weed.lat, weed.long),
    builder: (BuildContext ctx) => Icon(
        Icons.location_pin,
        size: Weed.size),
  );

  final Weed weed;
}

class WeedMarkerPopup extends StatelessWidget {
  const WeedMarkerPopup({Key? key, required this.weed})
      : super(key: key);
  final Weed weed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(weed.imagePath, width: 200),
            Text(weed.name),
            Text('${weed.lat}-${weed.long}'),
          ],
        ),
      ),
    );
  }
}

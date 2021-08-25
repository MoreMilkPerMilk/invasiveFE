import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers

/**
 * Architecture
 *
 * The main page consists of a scaffold, which fills with a flutter_map.
 * This map contains a series of markers. Markers are containers for widgets,
 * with some extra meta-data like geo-location which enables their placement on
 * the map, in the form of the widgets they contain.
 *
 * The widgets these markers contain are WeedMarkers. WeedMarkers are stateful
 * widgets which can be active (i.e. clicked on and displaying information) or
 * inactive. Each WeedMarker contains marker-specific WeedInformation such as the
 * weed name, and other data. They are built as IconButtons, though this can
 * easily be modified to any clickable widget (i.e. using GestureDetector).
 *
 * Each WeedMarker also contains a reference to a shared WeedOverlay class, which
 * represents the pop-up for selecting a marker. This class bundles together
 * information about whether an overlay is showing, a reference to the
 * OverlayState object and OverlayEntry object which are both necessary for
 * displaying and modifying the overlay, as well as the widget that the
 * OverlayEntry builds upon its display.
 *
 * The process of clicking a weed marker is as such:
 * The IconButton representing the WeedMarker is clicked.
 * The marker becomes active, is rebuilt, and may change appearance.
 * It alerts the WeedOverlay that is has been clicked, and provides its
 * weed information.
 * The WeedOverlay updates the widget contained in the OverlayEntry to contain
 * the marker's information. It then rebuilds the OverlayEntry so that these
 * changes are shown visually.
 * If the overlay was not already displaying, the WeedOverlay calls upon its
 * OverlayState to insert the OverlayEntry into the context, thus displaying it.
 * The overlay is now displayed with the marker's information on it.
 *
 * This architecture is extremely flexible, with one trade-off: you
 * can't have multiple overlays at once, since only one shared overlay entry is
 * used. If you want this functionality, you'll need to create a new overlay
 * entry for each WeedMarker, then pass this entry into the WeedOverlay to be
 * inserted by its OverlayState.
 *
 * or maybe we just create overlay entries on the fly, who knows:
 * https://medium.com/saugo360/https-medium-com-saugo360-flutter-using-overlay-to-display-floating-widgets-2e6d0e8decb9
 *
 * idea: modify the builder of the overlay entry upon refresh. cant because its final
 *
 * maybe make a
 *
 * idk
 */


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
            // enable pinchZoom and drag (move) only
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                WeedMarker(weedName)
              //   Container(
              //     child: IconButton(
              //       icon: Icon(
              //           Icons.location_pin,
              //           size: 40
              //       ),
              //       onPressed: () {
              //         print('Marker pressed!');
              //         var overlayState = Overlay.of(context);
              //         var overlayEntry;
              //
              //
              //         overlayEntry = OverlayEntry(
              //             builder: (context) =>
              //                 Center(
              //                     child: Material(
              //                         child: Container(
              //                             width: 100,
              //                             height: 100,
              //                             child: Column(
              //                                 mainAxisAlignment: MainAxisAlignment
              //                                     .center,
              //                                 children: <Widget>[
              //                                   Text(weedName),
              //                                   IconButton(
              //                                       onPressed: () {
              //                                         overlayEntry.remove();
              //                                       },
              //                                       icon: Icon(Icons.close)
              //                                   )
              //                                 ]
              //                             )
              //                         )
              //                     )));
              //         overlayState!.insert(overlayEntry);
              //       },
              //     )
              // )
    );
  }
}


class WeedMarker extends StatefulWidget {
  final String weedName;

  const WeedMarker(this.weedName);

  @override
  _WeedMarkerState createState() => _WeedMarkerState();
}

class _WeedMarkerState extends State<WeedMarker> {
  bool _active = false;

  void _handleTap() {
    setState(() {
      _active = !_active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Align(
          alignment: Alignment.center,
          child: IconButton(
            alignment: Alignment.center,
            icon: Icon(
              Icons.location_on,
              size: 40,
              color: _active ? Colors.red : Colors.blue,
            ),
            onPressed: () {
              _handleTap();
            },
          )
        )
    );
  }
}

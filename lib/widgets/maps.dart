import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers
// LOL good luck wading through this

/// fixme; James's big bug bash board:

/// todo; Features to develop:
/// Generating markers from a given file/object.
/// Nicer UI (overlays and markers).

const String MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucXRiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';
bool heatmapMode = false;

class MapsPage extends StatefulWidget {

  final PopupController _popupLayerController = PopupController();

  @override
  createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  bool heatmapMode = false;
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              FlutterMap(
                  options: MapOptions(
                    center: LatLng(-27.4975, 153.0137),
                    zoom: 13.0,
                    interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    onTap: (_) => widget._popupLayerController.hidePopup(),
                    plugins: [MarkerClusterPlugin(),],
                  ),
                  layers: heatmapMode ? [
                    TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: <String>['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(
                      markers: generateMarkers()
                    )
                  ] : [
                    TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: <String>['a', 'b', 'c'],
                    ),
                    MarkerClusterLayerOptions(
                      maxClusterRadius: 100,
                      size: Size(40, 40),
                      anchor: AnchorPos.align(AnchorAlign.center),
                      fitBoundsOptions: FitBoundsOptions(
                        padding: EdgeInsets.all(50),
                      ),
                      markers: generateMarkers(),
                      popupOptions: PopupOptions(
                          popupSnap: PopupSnap.markerTop,
                          popupController: widget._popupLayerController,
                          popupAnimation: PopupAnimation.fade(duration: Duration(milliseconds: 100)),
                          popupBuilder: (_, Marker marker) {
                            // this conditional is necessary since popupBuilder must take a Marker
                            if (marker is WeedMarker) {
                              return WeedMarkerPopup(weed: marker.weed);
                            }
                            return Card(child: Text('Error: Not a weed.'));
                          }
                      ),
                      builder: (context, markers) {
                        return FloatingActionButton(
                          onPressed: null,
                          child: Text(markers.length.toString()),
                        );
                      },
                    ),
                  ]
              ),
              Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: ToggleButtons(
                        borderWidth: 2,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("Marker View")
                            )
                          ),
                          Container(
                              color: Colors.white,
                              child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text("Heatmap View")
                              )
                          )
                        ],
                        onPressed: (int index) {
                          setState(() {
                            heatmapMode = index == 1;
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = false;
                            }
                            isSelected[index] = true;
                          });
                        },
                        isSelected: isSelected,
                      ),
                  )
              )
            ]
        )
    );
  }

  List<WeedMarker> generateMarkers() {
    return [
      WeedMarker(
        heatmap: heatmapMode,
        weed: Weed(
          name: 'Lantana',
          imagePath:
          'https://www.gardeningknowhow.com/wp-content/uploads/2020/11/pink-and-yellow-lantana-flowers-1024x768.jpg',
          lat: -27.4975,
          long: 153.0137,
        ),
      ),
      WeedMarker(
        heatmap: heatmapMode,
        weed: Weed(
          name: 'Winter Grass',
          imagePath:
          'https://www.myhometurf.com.au/wp-content/uploads/2019/11/Wintergrass-weed-600x600.jpg',
          lat: -27.4975,
          long: 153.0125,
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
  WeedMarker({required this.weed, required bool heatmap})
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    height: heatmap ? Weed.size * 2 : Weed.size,
    width: heatmap ? Weed.size * 2 : Weed.size,
    point: LatLng(weed.lat, weed.long),
    builder: heatmap ?
        (BuildContext ctx) => Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromRGBO(255, 0, 0, 0.5),
                Color.fromRGBO(255, 0, 0, 0)
              ]
            ),
            shape: BoxShape.circle,
          ),
        )
        :
        (BuildContext ctx) => Icon(
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


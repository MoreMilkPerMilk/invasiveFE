import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:invasive_fe/models/Council.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/gpsService.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:objectid/objectid.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers


const String MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucXRiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';
bool heatmapMode = false;
Map<int, dynamic> species = {};


class MapsPage extends StatefulWidget {

  final PopupController _popupLayerController = PopupController();

  @override
  createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<Marker> markers = [];
  bool heatmapMode = false;
  List<bool> isSelected = [true, false];
  late List<Polygon> councilPolygons = [];

  /// information that should be refreshed each time maps opens goes here
  @override
  void initState() {
    getAllPhotoLocations().then((locations) =>
      markers = locations.map((loc) => WeedMarker(
        photoLocation: loc,
        heatmap: heatmapMode)).toList());
    // fixme: for efficiency, this shouldn't be here
    getAllSpecies().then((speciesList) =>
      species = Map.fromIterable(speciesList, // convert species list to map for quick id lookup
          key: (e) => e.species_id,
          value: (e) => e));

    List<Council> councils = [];

    getCouncilById(ObjectId.fromHexString("613ef4c74ed77d2294042db4")).then((council) {
      // councils = councils_;
      // councils_.forEach((council) {
        print("council");
        print(council);
        print(council.boundary.toGeoJsonMultiPolygon().polygons.first.geoSeries.length);
        var polygon = List<LatLng>.from(council.boundary.toGeoJsonMultiPolygon().polygons.first.geoSeries.first.geoPoints.map(
                (x) => LatLng(x.latitude, x.longitude)
        ));
        print(polygon);
        print(polygon.length);
        councilPolygons.add(new Polygon(points: polygon, color: Color.fromRGBO(255, 0, 0, 0.2), borderColor: Color.fromRGBO(255, 0, 0, 1)));
      // });
    });


    // _polygons.add(new Polygon(points: _polygon, color: new Color.fromRGBO(
    //     255, 0, 0, 1.0)));
    print("ADD POLYGON");
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
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: <String>['a', 'b', 'c'],
                    ),
                    if (heatmapMode) MarkerLayerOptions(markers: markers)
                    else MarkerClusterLayerOptions(
                      maxClusterRadius: 100,
                      size: Size(40, 40),
                      anchor: AnchorPos.align(AnchorAlign.center),
                      fitBoundsOptions: FitBoundsOptions(
                        padding: EdgeInsets.all(50),
                      ),
                      markers: markers,
                      popupOptions: PopupOptions(
                          popupSnap: PopupSnap.markerTop,
                          popupController: widget._popupLayerController,
                          popupAnimation: PopupAnimation.fade(duration: Duration(milliseconds: 100)),
                          popupBuilder: (_, Marker marker) {
                            // this conditional is necessary since popupBuilder must take a Marker
                            if (marker is WeedMarker) {
                              return WeedMarkerPopup(photoLocation: marker.photoLocation);
                            }
                            return Card(child: Text('Error: Not a weed.'));
                          }),
                      builder: (context, markers) {
                        return FloatingActionButton(
                          onPressed: null,
                          child: Text(markers.length.toString()),
                        );},
                    ),
                    PolygonLayerOptions(polygons: councilPolygons)
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
}


class WeedMarker extends Marker {
  final PhotoLocation photoLocation;
  static final double markerSize = 40;

  WeedMarker({required this.photoLocation, required bool heatmap})
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    height: heatmap ? markerSize * 2 : markerSize,
    width: heatmap ? markerSize * 2 : markerSize,
    point: LatLng(photoLocation.location.geoPoint.latitude, photoLocation.location.geoPoint.longitude),
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
        size: markerSize),
  );
}


class WeedMarkerPopup extends StatelessWidget {
  const WeedMarkerPopup({Key? key, required this.photoLocation})
      : super(key: key);
  final PhotoLocation photoLocation;

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
          // children: photoLocation.weeds_present.map((weed) => Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     if (weed.image_filename != null) Image.network(weed.image_filename!, width: 200), // need to refactor this to use photoLOcation image
          //     Text(species[weed.species_id]),
          //     Text('${photoLocation.location.latitude}-${photoLocation.location.longitude}'),
          //   ],
          // )).toList()
        )
      ),
    );
  }
}


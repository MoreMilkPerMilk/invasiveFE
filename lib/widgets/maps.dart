import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/services/gpsService.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:objectid/objectid.dart';
import 'dart:io';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers

// token for mapbox tileservers, incase we ever use them
const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucXRiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';
// map of species id to Species objects; the entire species database
Map<int, Species> species = {};
// whether the map view mode is heat mode
bool communityView = false;

class MapsPage extends StatefulWidget {
  // controls showing and hiding map marker popups
  final PopupController _popupLayerController = PopupController();

  @override
  createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // list of locations to display as markers on the map
  List<Report> reports = [];
  // utility that specifies which view-mode button is selected
  List<bool> isSelected = [true, false];
  // the position of the user. defaults to the location of UQ, St. Lucia
  LatLng userPosition = LatLng(-27.4975, 153.0137);
  // the state of this future determines whether to display a loading screen
  late Future loaded;

  /// information that should be refreshed each time maps opens goes here
  @override
  void initState() {
    super.initState();
    Future reportsFuture = getAllReports();
    Future speciesFuture = getAllSpecies();
    Future positionFuture = determinePosition();

    // rather than here, we generate the markers in build() so they refresh on setState()
    reportsFuture.then((reports) => setState(() {
      this.reports = reports;
    }));

    // create the {species id => species} map
    speciesFuture.then((speciesList) => species = Map.fromIterable(
        speciesList, // convert species list to map for quick id lookup
        key: (e) => e.species_id,
        value: (e) => e));

    // set the user's position every X seconds
    positionFuture.then((position) => setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    }));

    Timer.periodic(Duration(seconds: 15), (timer) {
      if (this.mounted) {
        determinePosition().then((position) => setState(() {
          userPosition = LatLng(position.latitude, position.longitude);
        }));
      }
    });

    loaded = Future.wait([reportsFuture, speciesFuture, positionFuture]);
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = communityView ? [
      CommunityMarker(LatLng(-27.4475, 153.0137))
    ] : [
      WeedMarker(
        Report(
          id: ObjectId(),
          status: "status",
          notes: "notes",
          polygon: GeoJsonMultiPolygon(),
          photoLocations: [
            PhotoLocation(
                id: ObjectId(),
                photo: new File("assets/placeholder.png"),
                location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: -27.4975, longitude: 153.0137)),
                image_filename: 'placeholder.png'
            )
          ],
          name: "test",
          species_id: 41
        )
      )
    ];
    // List<WeedMarker> markers = reports.map((rep) => WeedMarker(report: rep)).toList();
    return Scaffold(
        body: Stack(children: [
      // this future builder returns a loading page until its given futures have
      // completed. built this way, the futures only have to be loaded once per
      // initState(), so we don't have to (for e.g.) send http requests every
      // time we rebuild the map. efficiency (taps head)
      FutureBuilder(
          future: loaded, // warning: never put a function call here
          builder: (context, snapshot) {
            // i.e. "if Future.wait([...]) gave us the all clear..."
            if (snapshot.connectionState == ConnectionState.done) {
              // all futures have completed; display the map
              return FlutterMap(
                  options: MapOptions(
                    // the default map location, upon opening the map
                    center: userPosition,
                    zoom: 13.0,
                    // disable map rotation for now
                    interactiveFlags:
                        InteractiveFlag.all & ~InteractiveFlag.rotate,
                    // hide all popups when the map is tapped
                    onTap: (_) => widget._popupLayerController.hidePopup(),
                    plugins: [MarkerClusterPlugin()],
                  ),
                  layers: [
                    // the tiles (i.e. appearance) of the map. not affected by view mode
                    TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: <String>['a', 'b', 'c'],
                    ),
                    // user location marker
                    MarkerLayerOptions(markers: [UserLocationMarker(userPosition)]),
                    // disable clustering and popups for heat map view
                    if (communityView)
                      MarkerLayerOptions(markers: markers)
                    // enable clustering and popups for pin view
                    else
                      MarkerClusterLayerOptions(
                        // max distance between two markers without clustering
                        maxClusterRadius: 50,
                        // cluster icon size
                        size: Size(40, 40),
                        // cluster icons are centred on the location
                        anchor: AnchorPos.align(AnchorAlign.center),
                        fitBoundsOptions: FitBoundsOptions(
                          padding: EdgeInsets.all(50),
                        ),
                        markers: markers,
                        // pop-up options are pretty self-explanatory
                        popupOptions: PopupOptions(
                            popupSnap: PopupSnap.markerTop,
                            popupController: widget._popupLayerController,
                            popupAnimation: PopupAnimation.fade(
                                duration: Duration(milliseconds: 100)),
                            popupBuilder: (_, Marker marker) {
                              if (marker is WeedMarker) return WeedMarkerPopup(report: marker.report);
                              else if (marker is CommunityMarker) return CommunityMarkerPopup(location: marker.location);
                              return Card(child: Text('Error: Not a weed marker or community marker.'));
                            }),
                        // widget to represent marker clusters
                        builder: (context, markers) {
                          return FloatingActionButton(
                            onPressed: null,
                            // handled by the MarkerClusterLayer
                            // display the number of markers clustered in the icon
                            child: Text(markers.length.toString()), // fixme: this number is the number of markers plus one, not the number of markers
                          );
                        },
                      ),
                  ]);
            } else {
              // the futures have not yet completed; display a loading page
              return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
              );
            }
          }),
      Padding(
          // space from the top of the screen
          padding: EdgeInsets.only(top: 50),
          child: Align(
            alignment: Alignment.topCenter,
            // ToggleButtons is the container for all of the buttons
            child: ToggleButtons(
              borderWidth: 2,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              // each child represents a separate button
              children: <Widget>[
                Container(
                    color: Colors.white,
                    child: Padding(
                        // add some space between the edge of the button and the inner text
                        padding: EdgeInsets.all(16),
                        child: Text("Weed Reports"))),
                Container(
                    color: Colors.white,
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Community")))
              ],
              // on click, ToggleButtons calls this function with the index of the clicked button
              onPressed: (int index) {
                // setState() rebuilds the map with the updated view mode
                setState(() {
                  // the heatmap button is the second button. this variable determines the map UI
                  communityView = index == 1;
                  // change the UI of the buttons to highlight which button was clicked
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = false;
                  }
                  isSelected[index] = true;
                });
              },
              // [true, false] or [false, true] depending on the selected button
              isSelected: isSelected,
            ),
          ))
    ]));
  }
}

/// a WeedMarker is a type of Marker which additionally stores information about
/// weeds captured at a Location
class WeedMarker extends Marker {
  // represents weed data
  final Report report;
  // size of this marker. must be the same as its widget's internal size, or
  // the visual size and hit-box size will be different
  static final double markerSize = 40;

  WeedMarker(this.report) : super(
    anchorPos: AnchorPos.align(AnchorAlign.top),
    height: markerSize,
    width: markerSize,
    point: LatLng(report.photoLocations.first.location.geoPoint.latitude,
        report.photoLocations.first.location.geoPoint.longitude),
    builder: (BuildContext ctx) => Icon(Icons.location_pin, size: markerSize),
  );
}

class CommunityMarker extends Marker {
  final LatLng location;
  static final double markerSize = 40;

  CommunityMarker(this.location) : super(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    point: location,
    height: markerSize,
    width: markerSize,
    builder: (BuildContext ctx) => Icon(Icons.people, size: markerSize)
  );
}

class UserLocationMarker extends Marker {
  // size of this marker. must be the same as its widget's internal size, or
  // the visual size and hit-box size will be different
  static final double markerSize = 40;

  UserLocationMarker(LatLng location)
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    // the code will be modified soon as heatmap bugs are fixed
    height: markerSize,
    width: markerSize,
    point: location,
    builder: (BuildContext ctx) => Icon(
      Icons.circle,
      size: markerSize,
      color: Colors.blue,
    )
  );
}

/// the on-click popup for a weed marker. built by the popupcontroller when a
/// weedmarker is clicked.
class WeedMarkerPopup extends StatelessWidget {
  const WeedMarkerPopup({Key? key, required this.report}) : super(key: key);
  // contains all the weed information, such as location and species
  final Report report;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // sexy curves
          ),
          child: Column(
            // a single weed information block, which is a column of weed information
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // present basic weed information
              Image.network(report.photoLocations.first.image_filename, width: 200),
              Text(species[report.species_id]!.name),
              Text('${report.photoLocations.first.location.geoPoint.latitude}-${report.photoLocations.first.location.geoPoint.longitude}'),
            ],
          )
      )
    );
  }
}

class CommunityMarkerPopup extends StatelessWidget {
  const CommunityMarkerPopup({Key? key, required this.location}) : super(key: key);
  // contains all the weed information, such as location and species
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // sexy curves
            ),
            child: Text("Community thing at ${location.latitude}, ${location.longitude}")
        )
    );
  }
}

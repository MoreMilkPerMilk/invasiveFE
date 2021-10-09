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
import 'package:invasive_fe/widgets/reportPage.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:objectid/objectid.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

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
    List<ReportMarker> reportMarkers = _debugReportMarkers();
    List<CommunityMarker> communityMarkers = _debugCommunityMarkers();

    // List<ReportMarker> markers = reports.map((rep) => ReportMarker(report: rep)).toList();
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
                        // todo: prone to further testing, this is the max zoom before the simulator for iphone 13 pro max wigs out
                        maxZoom: 18.4,
                        // fits australia nicely into one portrait-oriented screen, whilst not being so zoomed out that the countries turn white
                        minZoom: 3.5,
                        // disable map rotation for now
                        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        // hide all popups when the map is tapped
                        onTap: (_) {
                          widget._popupLayerController.hidePopup();
                        },
                        plugins: [MarkerClusterPlugin()],
                      ),
                      layers: [
                        _tileLayer(),
                        _userLocationMarker(),
                        if (communityView) _communityMarkers(communityMarkers)
                        else _reportMarkers(reportMarkers)
                      ]
                  );
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
                child: _toggleButtons(),
              )
          )
        ])
    );
  }

  TileLayerOptions _tileLayer() {
    return TileLayerOptions(
      urlTemplate: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
      subdomains: <String>['a', 'b'],
    );
  }

  MarkerLayerOptions _userLocationMarker() {
    return MarkerLayerOptions(markers: [UserLocationMarker(userPosition)]);
  }

  MarkerClusterLayerOptions _reportMarkers(List<ReportMarker> reportMarkers) {
    return MarkerClusterLayerOptions(
      // max distance between two markers without clustering
      maxClusterRadius: 50,
      // cluster icon size
      size: Size(40, 40),
      // cluster icons are centred on the location
      anchor: AnchorPos.align(AnchorAlign.center),
      fitBoundsOptions: FitBoundsOptions(
        padding: EdgeInsets.all(50),
      ),
      markers: reportMarkers,
      // pop-up options are pretty self-explanatory
      popupOptions: PopupOptions(
          popupSnap: PopupSnap.markerTop,
          popupController: widget._popupLayerController,
          popupAnimation: PopupAnimation.fade(duration: Duration(milliseconds: 100)),
          popupBuilder: (_, Marker marker) {
            if (marker is CommunityMarker) return CommunityMarkerPopup(location: marker.location);
            else return ReportMarkerPopup(report: (marker as ReportMarker).report);
          }),
      // widget to represent marker clusters
      builder: (context, markers) {
        return FloatingActionButton(
          onPressed: null,
          // handled by the MarkerClusterLayer
          // display the number of markers clustered in the icon
          child: Text(markers.length.toString()),
        );
      },
    );
  }

  MarkerClusterLayerOptions _communityMarkers(List<CommunityMarker> communityMarkers) {
    return MarkerClusterLayerOptions(
      // max distance between two markers without clustering
      maxClusterRadius: 50,
      // cluster icon size
      size: Size(40, 40),
      // cluster icons are centred on the location
      anchor: AnchorPos.align(AnchorAlign.center),
      fitBoundsOptions: FitBoundsOptions(
        padding: EdgeInsets.all(50),
      ),
      markers: communityMarkers,
      // pop-up options are pretty self-explanatory
      popupOptions: PopupOptions(
          popupSnap: PopupSnap.markerTop,
          popupController: widget._popupLayerController,
          popupAnimation: PopupAnimation.fade(duration: Duration(milliseconds: 100)),
          popupBuilder: (_, Marker marker) {
            if (marker is CommunityMarker) return CommunityMarkerPopup(location: marker.location);
            else return ReportMarkerPopup(report: (marker as ReportMarker).report);
          }),
      // widget to represent marker clusters
      builder: (context, markers) {
        return FloatingActionButton(
          onPressed: null,
          // handled by the MarkerClusterLayer
          // display the number of markers clustered in the icon
          child: Text(markers.length.toString()),
        );
      },
    );
  }

  ToggleButtons _toggleButtons() {
    return ToggleButtons(
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
          // if changing tabs, hide all popups
          if (communityView != (index == 1)) widget._popupLayerController.hidePopup();
          // the community view button is the second button. this variable determines the map UI
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
    );
  }

  List<ReportMarker> _debugReportMarkers() {
    return [
      ReportMarker(
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
                    image_filename: 'assets/placeholder.png'
                )
              ],
              name: "test",
              species_id: 41
          )
      )
    ];
  }

  List<CommunityMarker> _debugCommunityMarkers() {
    return [CommunityMarker(LatLng(-27.4475, 153.0137))];
  }
}

/// a type of Marker which additionally stores information about a report
class ReportMarker extends Marker {
  // represents report data
  final Report report;
  // size of this marker. must be the same as its widget's internal size, or
  // the visual size and hit-box size will be different
  static final double markerSize = 30;

  ReportMarker(this.report) : super(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    height: markerSize,
    width: markerSize,
    point: LatLng(report.photoLocations.first.location.geoPoint.latitude,
        report.photoLocations.first.location.geoPoint.longitude),
    builder: (BuildContext ctx) => Icon(Icons.grass, size: markerSize),
  );
}

class CommunityMarker extends Marker {
  final LatLng location;
  static final double markerSize = 30;

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
  static final double markerSize = 30;

  UserLocationMarker(LatLng location)
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    // the code will be modified soon as heatmap bugs are fixed
    height: markerSize,
    width: markerSize,
    point: location,
    builder: (BuildContext ctx) => Stack(
     alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          size: markerSize,
          color: Colors.white,
        ),
        Icon(
          Icons.circle,
          size: markerSize * 0.7,
          color: Colors.blue
        )
      ]
    )
  );
}

/// the on-click popup for a report marker. built by the popupcontroller when a reportmarker is clicked.
class ReportMarkerPopup extends StatelessWidget {
  // contains all the report information, such as location and species
  final Report report;
  static final TextStyle bodyFont = GoogleFonts.openSans(
      fontSize: 12,
  );

  const ReportMarkerPopup({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Species thisSpecies = species[report.species_id]!;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportPage(report: report),
          )
      ),
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // sexy curves
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // present basic report information
                Padding(
                    padding: EdgeInsets.all(3),
                    child: Container(
                        width: 90, // we're going to get a width x width box. note AspectRatio will ensure width = height
                        clipBehavior: Clip.hardEdge, // to clip the rounded corners
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge, // to clip the image into a square
                                child: Image.asset(report.photoLocations.first.image_filename)
                            )
                        )
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10)
                ),
                Container(
                  width: 200,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(thisSpecies.name,
                            style: GoogleFonts.openSans(
                                fontSize: 12
                            )
                        ),
                        Text('${report.photoLocations.first.location.geoPoint.latitude}-${report.photoLocations.first.location.geoPoint.longitude}',
                            style: GoogleFonts.openSans(
                                fontSize: 12
                            )
                        ),
                        Text(thisSpecies.council_declaration,
                            style: GoogleFonts.openSans(
                                fontSize: 12
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 5)
                        ),
                        SeverityBar(1)
                      ]
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10)
                ),
                Icon(
                    Icons.arrow_forward_ios
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10)
                ),
              ]
          )
      ),
    );
  }
}

class CommunityMarkerPopup extends StatelessWidget {
  const CommunityMarkerPopup({Key? key, required this.location}) : super(key: key);
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

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:invasive_fe/models/Community.dart';
import 'package:invasive_fe/models/Council.dart';
import 'package:invasive_fe/models/Landcare.dart';
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
import 'package:random_color/random_color.dart';
import 'package:geodesy/geodesy.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'mapPanel.dart';

// openstreetmap tile servers: https://wiki.openstreetmap.org/wiki/Tile_servers

// token for mapbox tileservers, incase we ever use them
const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoianNsdm4iLCJhIjoiY2tzZTFoYmltMHc5ajJucXRiczY3eno3bSJ9.We8R6YRT_fcmuC6bOzzqbw';
// map of species id to Species objects; the entire species database
Map<int, Species> species = {};
// whether the map view mode is heat mode
bool heatmapMode = false;
bool councilMode = false;
bool communityView = false;
bool communityMode = false;
bool reportsMode = false;
bool landcareMode = false;

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

  //list of council polygons to draw on the map
  List<Polygon> councilPolygons = [];

  //list of community polygons to draw on the map
  List<Polygon> communityPolygons = [];

  //list of council polygons to draw on the map
  List<Polygon> reportPolygons = [];

  //list of council polygons to draw on the map
  List<Polygon> landcarePolygons = [];

  //list of councils
  List<Council> councils = [];

  //list of communities
  List<Community> communities = [];

  // map position bounds for council fetching
  MapPosition _lastMapPosition = new MapPosition();

  //council colors for displaying polygons
  HashMap<String, Color> councilColors = new HashMap();

  //landcare colors for displaying polygons
  HashMap<String, Color> landcareColors = new HashMap();

  //community colors for displaying polygons
  HashMap<String, Color> communityColors = new HashMap();

  //reports colors for polygons
  HashMap<String, Color> reportsColors = new HashMap();

  //panel
  PanelController _pc = new PanelController();

  Council? selectedCouncil = null;
  Community? selectedCommunity = null;
  Landcare? selectedLandcare = null;

  //drop down value
  late String? dropDownValue = null;

  late List<ReportMarker> reportMarkers = [];

  var dropDownKey;

  /// information that should be refreshed each time maps opens goes here
  @override
  void initState() {
    super.initState();
    dropDownKey = GlobalKey();
    Future<List<Report>> reportsFuture = getAllReports();
    Future speciesFuture = getAllSpecies();
    Future positionFuture = determinePosition();

    // rather than here, we generate the markers in build() so they refresh on setState()
    reportsFuture.then((reports) {
      setState(() {
        this.reports = reports;
        reportMarkers =
            reports.map<ReportMarker>((Report r) => ReportMarker(r)).toList();

        //polygons
        reportPolygons = reports.map<Polygon>((Report r) {
          List<LatLng> polygon = [];
          if (r.polygon != null && r.polygon.polygons.length > 0) {
            polygon = List<LatLng>.from(r
                .polygon.polygons.first.geoSeries.first.geoPoints
                .map((x) => LatLng(x.latitude, x.longitude)));

            if (polygon.length > 0) polygon.add(polygon.first);
          }

          return new Polygon(
              points: polygon,
              color: Color.fromRGBO(255, 0, 0, 0.2),
              borderColor: Color.fromRGBO(255, 0, 0, 1),
              borderStrokeWidth: 1,
              isDotted: true);
        }).toList();
      });
    });

    // create the {species id => species} map
    speciesFuture.then((speciesList) => species = Map.fromIterable(
        speciesList, // convert species list to map for quick id lookup
        key: (e) => e.species_id,
        value: (e) => e));

    Timer.periodic(Duration(seconds: 5), (timer) {
      if (!this.mounted) return;

      if (councilMode) {
        Future<List<Council>> councilPolygonFuture =
            getCouncilsInMapBounds(_lastMapPosition);
        //get the council for the user's position
        councilPolygonFuture.then((councils) => setState(() {
              this.councilPolygons = [];
              this.councils = [];
              this.councils = councils;
              councils.forEach((council) {
                var polygon;
                if (council.boundary.toGeoJsonMultiPolygon().polygons.length >
                    0) {
                  polygon = List<LatLng>.from(council.boundary
                      .toGeoJsonMultiPolygon()
                      .polygons
                      .first
                      .geoSeries
                      .first
                      .geoPoints
                      .map((x) => LatLng(x.latitude, x.longitude)));
                } else {
                  return;
                }
                // this.councilPolygons.add(new Polygon(points: points))
                Color _color = new Color.fromRGBO(255, 0, 0, 0.1);
                if (this.councilColors[council.id.toString()] != null) {
                  Color? tmp = this.councilColors[council.id.toString()];
                  if (tmp != null) {
                    _color = tmp;
                  }
                } else {
                  RandomColor _randomColor = RandomColor();
                  _color = _randomColor.randomColor();
                  this.councilColors[council.id.toString()] = _color;
                }
                //add a polygon per council
                this.councilPolygons.add(new Polygon(
                    points: polygon,
                    color: Color.fromRGBO(
                        _color.red, _color.green, _color.blue, 0.4),
                    borderColor: Color.fromRGBO(0, 0, 0, 1),
                    borderStrokeWidth: 1));
              });
            }));
      }
      if (communityMode) {
        Future<List<Community>> communityPolygonFuture =
            getCommunitiesInMapBounds(_lastMapPosition);
        //get the council for the user's position
        communityPolygonFuture.then((communities) => setState(() {
              this.communityPolygons = [];
              this.communities = communities;
              communities.forEach((community) {
                var polygon;
                if (community.boundary.toGeoJsonMultiPolygon().polygons.length >
                    0) {
                  polygon = List<LatLng>.from(community.boundary
                      .toGeoJsonMultiPolygon()
                      .polygons
                      .first
                      .geoSeries
                      .first
                      .geoPoints
                      .map((x) => LatLng(x.latitude, x.longitude)));
                } else {
                  return;
                }
                Color _color = new Color.fromRGBO(255, 0, 0, 0.1);
                if (this.communityColors[community.id.toString()] != null) {
                  Color? tmp = this.communityColors[community.id.toString()];
                  if (tmp != null) {
                    _color = tmp;
                  }
                } else {
                  RandomColor _randomColor = RandomColor();
                  _color = _randomColor.randomColor();
                  this.communityColors[community.id.toString()] = _color;
                }
                //add a polygon per council
                this.communityPolygons.add(new Polygon(
                      points: polygon,
                      color: Color.fromRGBO(
                          _color.red, _color.green, _color.blue, 0.4),
                      borderColor: Color.fromRGBO(0, 0, 0, 1),
                      borderStrokeWidth: 1,
                    ));
              });
            }));
      }
      if (landcareMode) {
        Future<List<Landcare>> communityPolygonFuture =
            getLandcaresInMapBounds(_lastMapPosition);
        //get the council for the user's position
        communityPolygonFuture.then((landcares) => setState(() {
              this.landcarePolygons = [];
              landcares.forEach((landcare) {
                print("landcare = " + landcare.toString());
                var polygon;
                if (landcare.boundary.toGeoJsonMultiPolygon().polygons.length >
                    0) {
                  polygon = List<LatLng>.from(landcare.boundary
                      .toGeoJsonMultiPolygon()
                      .polygons
                      .first
                      .geoSeries
                      .first
                      .geoPoints
                      .map((x) => LatLng(x.latitude, x.longitude)));
                } else {
                  return;
                }
                Color _color = new Color.fromRGBO(255, 0, 0, 0.1);
                if (this.landcareColors[landcare.id.toString()] != null) {
                  Color? tmp = this.landcareColors[landcare.id.toString()];
                  if (tmp != null) {
                    _color = tmp;
                  }
                } else {
                  RandomColor _randomColor = RandomColor();
                  _color = _randomColor.randomColor();
                  this.landcareColors[landcare.id.toString()] = _color;
                }
                //add a polygon per council
                this.landcarePolygons.add(new Polygon(
                    points: polygon,
                    color: Color.fromRGBO(
                        _color.red, _color.green, _color.blue, 0.4),
                    borderColor: Color.fromRGBO(0, 0, 0, 1),
                    borderStrokeWidth: 1));
              });
            }));
      }
    });

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
    // List<ReportMarker> reportMarkers = _debugReportMarkers();
    List<CommunityMarker> communityMarkers = _debugCommunityMarkers();

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

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
              return Container(
                  child: SlidingUpPanel(
                      backdropEnabled: true,
                      controller: _pc,
                      minHeight: 0,
                      maxHeight: 300,
                      borderRadius: radius,
                      panel: MapPanel(_pc, selectedCouncil, selectedCommunity,
                          selectedLandcare),
                      body: FlutterMap(
                          options: MapOptions(
                            // the default map location, upon opening the map
                            center: userPosition,
                            zoom: 13.0,
                            // todo: prone to further testing, this is the max zoom before the simulator for iphone 13 pro max wigs out
                            maxZoom: 18.4,
                            // fits australia nicely into one portrait-oriented screen, whilst not being so zoomed out that the countries turn white
                            minZoom: 3.5,
                            // disable map rotation for now
                            interactiveFlags:
                                InteractiveFlag.all & ~InteractiveFlag.rotate,
                            // hide all popups when the map is tapped
                            onTap: (LatLng posTapped) {
                              widget._popupLayerController.hidePopup();
                              bool found = false;
                              if (communityMode) {
                                this.communities.forEach((Community community) {
                                  List<LatLng> pts = [];
                                  if (community.boundary.polygons.length > 0) {
                                    community.boundary.polygons.first.geoSeries
                                        .first.geoPoints
                                        .forEach((GeoPoint geoPoint) {
                                      pts.add(LatLng(geoPoint.latitude,
                                          geoPoint.longitude));
                                    });
                                  }
                                  // print(pts);

                                  Geodesy geodesy = Geodesy();
                                  if (geodesy.isGeoPointInPolygon(
                                      posTapped, pts)) {
                                    setState(() {
                                      selectedCommunity = community;
                                      selectedCouncil = null;
                                      selectedLandcare = null;
                                      found = true;
                                      _pc.open();
                                    });
                                  }
                                });
                              }
                              if (councilMode && !found) {
                                this.councils.forEach((Council council) {
                                  List<LatLng> pts = [];
                                  if (council.boundary.polygons.length > 0) {
                                    council.boundary.polygons.first.geoSeries
                                        .first.geoPoints
                                        .forEach((GeoPoint geoPoint) {
                                      pts.add(LatLng(geoPoint.latitude,
                                          geoPoint.longitude));
                                    });
                                  }

                                  Geodesy geodesy = Geodesy();
                                  if (geodesy.isGeoPointInPolygon(
                                      posTapped, pts)) {
                                    setState(() {
                                      selectedCouncil = council;
                                      _pc.open();
                                    });
                                  }
                                });
                              }
                            },
                            // update the bounds for drawing polygons
                            onPositionChanged: (MapPosition position, _) {
                              _lastMapPosition = position;
                            },
                            plugins: [MarkerClusterPlugin()],
                          ),
                          layers: [
                            _tileLayer(),
                            //has to show below markers
                            _landcarePolygonLayer(),
                            _councilPolygonLayer(),
                            _communityPolygonLayer(),
                            _reportPolygonLayer(),
                            _userLocationMarker(),
                            if (communityView)
                              _communityMarkers(communityMarkers)
                            else
                              _reportMarkers(reportMarkers)
                          ])));
            } else {
              // the futures have not yet completed; display a loading page
              return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
            }
          }),
      Padding(
          // space from the top of the screen
          padding: EdgeInsets.only(top: 50),
          child: Align(
            alignment: Alignment.topCenter,
            // ToggleButtons is the container for all of the buttons
            child: _toggleButtons(),
          )),
      Padding(
          // space from the top of the screen
          padding: EdgeInsets.only(bottom: 30, left: 10),
          child: Align(
              alignment: Alignment.bottomLeft,
              // DropdownButton for different polygon layers
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  setState(() {
                    Future<List<Report>> reportsFuture = getAllReports();
                    loaded = reportsFuture;

                    reportsFuture.then((reports) {
                      this.reports = reports;
                      reportMarkers = reports
                          .map<ReportMarker>((Report r) => ReportMarker(r))
                          .toList();
                    });
                  });
                },
                child: Icon(Icons.refresh),
              ))),
      _layerDropDownPadding(),
    ]));
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
          popupAnimation:
              PopupAnimation.fade(duration: Duration(milliseconds: 100)),
          popupBuilder: (_, Marker marker) {
            if (marker is CommunityMarker)
              return CommunityMarkerPopup(location: marker.location);
            else
              return ReportMarkerPopup(report: (marker as ReportMarker).report);
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

  PolygonLayerOptions _councilPolygonLayer() {
    //only draw when enabled.
    if (councilMode) return PolygonLayerOptions(polygons: councilPolygons);

    return PolygonLayerOptions(polygons: []);
  }

  PolygonLayerOptions _communityPolygonLayer() {
    //only draw when enabled.
    if (communityMode) return PolygonLayerOptions(polygons: communityPolygons);

    return PolygonLayerOptions(polygons: []);
  }

  PolygonLayerOptions _landcarePolygonLayer() {
    //only draw when enabled.
    if (landcareMode) return PolygonLayerOptions(polygons: landcarePolygons);

    return PolygonLayerOptions(polygons: []);
  }

  PolygonLayerOptions _reportPolygonLayer() {
    if (reportsMode) return PolygonLayerOptions(polygons: reportPolygons);

    return PolygonLayerOptions(polygons: []);
  }

  MarkerClusterLayerOptions _communityMarkers(
      List<CommunityMarker> communityMarkers) {
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
          popupAnimation:
              PopupAnimation.fade(duration: Duration(milliseconds: 100)),
          popupBuilder: (_, Marker marker) {
            if (marker is CommunityMarker)
              return CommunityMarkerPopup(location: marker.location);
            else
              return ReportMarkerPopup(report: (marker as ReportMarker).report);
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
            child:
                Padding(padding: EdgeInsets.all(16), child: Text("Community")))
      ],
      // on click, ToggleButtons calls this function with the index of the clicked button
      onPressed: (int index) {
        // setState() rebuilds the map with the updated view mode
        setState(() {
          // if changing tabs, hide all popups
          if (communityView != (index == 1))
            widget._popupLayerController.hidePopup();
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

  StatefulBuilder _layerDropDownPadding() {
    int _dropDownValue = 0;
    bool _dropDownOpen = false;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setBuilderState) {
      return Padding(
          // space from the top of the screen
          padding: EdgeInsets.only(bottom: 30, right: 10),
          child: Align(
              alignment: Alignment.bottomRight,
              // DropdownButton for different polygon layers
              child: Container(
                  color: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: DropdownButton(
                        key: dropDownKey,
                        value: _dropDownValue,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  onChanged: (bool? value) {
                                    setBuilderState(() {
                                      councilMode = !councilMode;
                                      // value = councilMode;
                                      _dropDownValue = 0;
                                      if (_dropDownOpen &&
                                          Navigator.canPop(
                                              dropDownKey.currentContext)) {
                                        Navigator.pop(
                                            dropDownKey.currentContext);
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MapsPage()));
                                      }
                                    });
                                  },
                                  value: councilMode,
                                ),
                                Text('Councils'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  onChanged: (bool? value) {
                                    setBuilderState(() {
                                      reportsMode = !reportsMode;
                                      _dropDownValue = 1;
                                      if (_dropDownOpen &&
                                          Navigator.canPop(
                                              dropDownKey.currentContext)) {
                                        Navigator.pop(
                                            dropDownKey.currentContext);
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MapsPage()));
                                      }
                                    });
                                  },
                                  value: reportsMode,
                                ),
                                Text('Report Impacts'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  onChanged: (bool? value) {
                                    setBuilderState(() {
                                      communityMode = !communityMode;
                                      _dropDownValue = 2;
                                      if (_dropDownOpen &&
                                          Navigator.canPop(
                                              dropDownKey.currentContext)) {
                                        Navigator.pop(
                                            dropDownKey.currentContext);
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MapsPage()));
                                      }
                                    });
                                  },
                                  value: communityMode,
                                ),
                                Text('Communities'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  onChanged: (bool? value) {
                                    setBuilderState(() {
                                      landcareMode = !landcareMode;
                                      _dropDownValue = 3;
                                      if (_dropDownOpen &&
                                          Navigator.canPop(
                                              dropDownKey.currentContext)) {
                                        Navigator.pop(
                                            dropDownKey.currentContext);
                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MapsPage()));
                                      }
                                    });
                                  },
                                  value: landcareMode,
                                ),
                                Text('Landcare'),
                              ],
                            ),
                          )
                        ],
                        onChanged: (int? value) {
                          setBuilderState(() {
                            _dropDownValue = value!;
                          });
                        },
                        onTap: () {
                          setBuilderState(() {
                            _dropDownOpen = !_dropDownOpen;
                          });
                        },
                      )))));
    });
  }

  List<ReportMarker> _debugReportMarkers() {
    return [
      ReportMarker(Report(
          id: ObjectId(),
          status: "status",
          notes: "notes",
          polygon: GeoJsonMultiPolygon(),
          photoLocations: [
            PhotoLocation(
                id: ObjectId(),
                photo: new File("assets/placeholder.png"),
                location: GeoJsonPoint(
                    geoPoint:
                        new GeoPoint(latitude: -27.4975, longitude: 153.0137)),
                image_filename: 'assets/placeholder.png')
          ],
          name: "test",
          species_id: 41))
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

  ReportMarker(this.report)
      : super(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          height: markerSize,
          width: markerSize,
// point: LatLng(report.photoLocations.length > 0 ? report.photoLocations.first.location.geoPoint.latitude : 0,
// report.photoLocations.length > 0 ? report.photoLocations.first.location.geoPoint.longitude : 0),
          point: calculateCentre(report),
// point: report.center,
          builder: (BuildContext ctx) => Icon(Icons.grass, size: markerSize),
        );

  static LatLng calculateCentre(Report report) {
    double latSum = 0;
    double longSum = 0;
    int n = 0;
    GeoJsonMultiPolygon multiPolygon = report.polygon;
    if (multiPolygon.polygons.length > 0) {
//averages points
      multiPolygon.polygons.first.geoSeries.first.geoPoints
          .forEach((GeoPoint geoPoint) {
        latSum += geoPoint.latitude;
        longSum += geoPoint.longitude;
        n++;
      });
    } else {
//no polygon default to first photolocation
      if (report.photoLocations.length > 0) {
        return LatLng(report.photoLocations.first.location.geoPoint.latitude,
            report.photoLocations.first.location.geoPoint.longitude);
      }
    }

    return LatLng(latSum / n, longSum / n);
  }
}

class CommunityMarker extends Marker {
  final LatLng location;
  static final double markerSize = 30;

  CommunityMarker(this.location)
      : super(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            point: location,
            height: markerSize,
            width: markerSize,
            builder: (BuildContext ctx) =>
                Icon(Icons.people, size: markerSize));
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
            builder: (BuildContext ctx) =>
                Stack(alignment: Alignment.center, children: [
                  Icon(
                    Icons.circle,
                    size: markerSize,
                    color: Colors.white,
                  ),
                  Icon(Icons.circle, size: markerSize * 0.7, color: Colors.blue)
                ]));
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
          MaterialPageRoute(
            builder: (context) => ReportPage(report: report),
          )),
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // sexy curves
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            // present basic report information
            Padding(
                padding: EdgeInsets.all(3),
                child: Container(
                    width: 90,
                    // we're going to get a width x width box. note AspectRatio will ensure width = height
                    clipBehavior: Clip.hardEdge,
                    // to clip the rounded corners
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            // to clip the image into a square
                            child: Image.network(
                                getImageURL(report.photoLocations.first)
                                    .toString()))))),
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 200,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thisSpecies.name,
                        style: GoogleFonts.openSans(fontSize: 12)),
                    Text(
                        '${report.photoLocations.first.location.geoPoint.latitude}-${report.photoLocations.first.location.geoPoint.longitude}',
                        style: GoogleFonts.openSans(fontSize: 12)),
                    Text(thisSpecies.council_declaration,
                        style: GoogleFonts.openSans(fontSize: 12)),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    SeverityBar(1)
                  ]),
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Icon(Icons.arrow_forward_ios),
            Padding(padding: EdgeInsets.only(left: 10)),
          ])),
    );
  }
}

class CommunityMarkerPopup extends StatelessWidget {
  const CommunityMarkerPopup({Key? key, required this.location})
      : super(key: key);
  final LatLng location;

  // final Community community;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // sexy curves
            ),
            child: Text(
                "Community thing at ${location.latitude}, ${location.longitude}")));
  }
}

class CouncilMarkerPopup extends StatelessWidget {
  const CouncilMarkerPopup(
      {Key? key, required this.location, required this.council})
      : super(key: key);
  final LatLng location;
  final Council council;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // sexy curves
            ),
            child: Text(
                "council thing at ${location.latitude}, ${location.longitude}")));
  }
}

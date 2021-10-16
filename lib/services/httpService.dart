import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show ByteData, PlatformException, rootBundle;
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/src/media_type.dart';

import 'package:invasive_fe/models/Community.dart';
import 'package:invasive_fe/models/Council.dart';
import 'package:invasive_fe/models/Event.dart';
import 'package:invasive_fe/models/MultiPolygon.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_mac/get_mac.dart';

const API_URL = 'http://35.244.125.224';

// --------------------------------
//  PROGRESS
// [x] GET locations
// [x] POST add locations
// [x] POST delete locations
// [x] GET species
// [x] GET species by id
// [x] GET users
// [x] GET users by id
// [x] POST add users
// [x] POST delete users
// [] POST update users
// --------------------------------


// --------------------------------
//  LOCATIONS
// --------------------------------

/// get all PhotoLocations in the Collection
Future<List<PhotoLocation>> getAllPhotoLocations() async {
  final response = await http.get(Uri.parse(API_URL + "/photolocations"));

  if (response.statusCode == 200) {
    var result = PhotoLocation.parsePhotoLocationList(response.body);

    return result;
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

/// create location
Future<PhotoLocation> createLocation(PhotoLocation location) async {
  final response = await http.post(
    Uri.parse(API_URL + "/photolocations/create"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: location.toJson(),
  );

  if (response.statusCode == 200) {
    return PhotoLocation.fromJson(jsonDecode(response.body));
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//upload photo to an already present PhotoLocation
Future<PhotoLocation> uploadPhotoToPhotoLocation(String filename,
    Stream<List<int>> stream, int streamLength, String photoLocationId) async {
  var request = http.MultipartRequest(
    'POST', Uri.parse(API_URL + "/photolocations/uploadphoto/${photoLocationId}"),
  );
  Map<String,String> headers={
    'accept': 'application/json',
    "Content-type": "multipart/form-data"
  };
  request.files.add(
    http.MultipartFile(
      'file', //field
      stream, //bytes
      streamLength, //length
      filename: filename, // filename
      contentType: MediaType('image', filename.split(".").last),
    ),
  );
  request.headers.addAll(headers);

  StreamedResponse res = await request.send();
  var s = await res.stream.bytesToString();

  if (res.statusCode == 200) {
    return PhotoLocation.fromJson(jsonDecode(s));
  }

  throw "HTTP Error Code: ${res.statusCode} http response = ${s}";
}

/// add PhotoLocation, creates a PhotoLocation, then uploads the photo to it
Future<PhotoLocation> addPhotoLocation(PhotoLocation photoLocation) async {
  //create
  PhotoLocation loc = await createLocation(photoLocation);

  var f = XFile(photoLocation.photo.path);
  int length = await f.length();

  loc = await uploadPhotoToPhotoLocation(photoLocation.photo.path,
      f.readAsBytes().asStream(), length, loc.id.toString());

  photoLocation.image_filename = loc.image_filename;

  return photoLocation;
}

/// delete location
Future<bool> deleteLocation(PhotoLocation location) async {
  final response = await http.post(
    Uri.parse(API_URL + "/photolocations/delete"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: location.toJson(),
  );

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

/// get image from a photolocation
Uri getImageURL(PhotoLocation location) {
  return Uri.parse(API_URL + "/files/${location.image_filename}");
}

// --------------------------------
//  REPORTS
// --------------------------------

/// add Report
Future<Report> addReport(Report report) async {
  final response = await http.post(
    Uri.parse(API_URL + "/reports/add"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: report.toJson(),
  ).timeout(const Duration(seconds: 4)); //timeout for testing

  if (response.statusCode == 200) {
    return Report.fromJson(jsonDecode(response.body));
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body.toString()}";
}

/// add a PhotoLocation to a Report
Future<Report> addPhotoLocationToReport(Report report, PhotoLocation photoLocation) async {
  //build query string
  String url = API_URL + "/reports/addphotolocationbyid?location_id=${photoLocation.id}&report_id=${report.id}";
  final response = await http.put(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: report.toJson(),
  ).timeout(const Duration(seconds: 4)); //timeout for testing

  if (response.statusCode == 200) {
    return Report.fromJson(jsonDecode(response.body));
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body.toString()}";
}

// --------------------------------
//  USERS
// --------------------------------

/// communicate with backend server to HTTP GET all users.
Future<List<User>> getAllUsers() async {
  final response = await http.get(Uri.parse(API_URL + "/users"));

  if (response.statusCode == 200) {
    var result = User.parseUserList(response.body);
    return result;
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//creates user if doesn't exist
Future<User> getCurrentUser() async {
  String macAddress = "unkown_mac";
  try {
    macAddress = await GetMac.macAddress;
  } on PlatformException {
    macAddress = 'unkown_mac';
  }

  final response = await http.get(Uri.parse(API_URL + "/users/createbymacaddress/${macAddress}"));

  if (response.statusCode == 200) {
    var result = User.fromJson(jsonDecode(response.body));
    return result;
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

/// communicate with backend server to HTTP GET a specific user.
Future<User> getUserById(int personId) async {
  final response = await http.get(
      Uri.parse(API_URL + "/users/$personId"));

  if (response.statusCode == 200) {
    var result = User.fromJson(jsonDecode(response.body));
    return result;
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

/// add User
Future<User> addUser(User user) async {

  final response = await http.post(
    Uri.parse(API_URL + "/users/create"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: user.toJson(),
  ).timeout(const Duration(seconds: 4)); //timeout for testing

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

/// add a Report to a User
Future<User> addReportToUser(Report report, User user) async {
  //build query string
  String url = API_URL + "/users/addreportbyid?report_id=${report.id},user_id=${user.id}";
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: report.toJson(),
  ).timeout(const Duration(seconds: 4)); //timeout for testing

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

/// delete User
Future<bool> deleteUser(int personId) async {
  final response = await http.delete(
      Uri.parse(API_URL + "/users/delete?person_id=$personId"),
  );

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

// --------------------------------
//  SPECIES
// --------------------------------

Future<List<Species>> getAllSpecies() async {
  final response = await http.get(Uri.parse(API_URL + "/species"));

  if (response.statusCode == 200) {
    var result = Species.parseSpeciesList(response.body);

    return result;
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

Future<Species> getSpeciesById(int speciesID) async {
  final response = await http.get(
      Uri.parse(API_URL + "/species/?species_id=$speciesID"));

  if (response.statusCode == 200) {
    return Species.fromJson(jsonDecode(response.body));
  }
  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//gets first Species by a given speciesName
Future<Species> getSpeciesByName(String speciesName) async {
  final response = await http.get(
      Uri.parse(API_URL + "/species/search/species_name=$speciesName"));

  if (response.statusCode == 200) {
    var decodedJson = jsonDecode(response.body);
    return Species.fromJson(decodedJson[0]);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

// --------------------------------
//  Councils
// --------------------------------
Future<List<Council>> getAllCouncils() async {
  final response = await http.get(Uri.parse(API_URL + "/councils/peek"));

  if (response.statusCode == 200) {
    return Council.parseCouncilList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//gets a council by it's id
Future<Council> getCouncilById(ObjectId council_id) async {
  final response = await http.get(Uri.parse(API_URL + "/councils/${council_id.toString()}"));

  if (response.statusCode == 200) {
    var result = Council.parseCouncilList(response.body);
    return result.first;
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//search for councils by a search term
Future<List<Council>> searchForCouncilBySearchTerm(String search_term) async {
  final response = await http.get(Uri.parse(API_URL + "/councils/search?search_term=$search_term"));
  if (response.statusCode == 200) {
    return Council.parseCouncilList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//search for councils occupying a location
Future<List<Council>> searchForCouncilByLocation(PhotoLocation location) async {
  final response = await http.post(
    Uri.parse(API_URL + "/councils/search/location"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: location.toJson(),
  );
  if (response.statusCode == 200) {
    return Council.parseCouncilList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

double fixLatLong(double latlong) {
  if (latlong == null)
    return 0;

  return latlong;
}

//get councils in bounds of the FlutterMap
Future<List<Council>> getCouncilsInMapBounds(MapPosition position) async {

  //create polygon
  if (position.bounds == null) {
    return [];
  }
  List<GeoPoint> geoPoints = [
    //don't change any "!"
    new GeoPoint(latitude: fixLatLong(position.bounds!.northWest.latitude), longitude: fixLatLong(position.bounds!.northWest.longitude)),
    new GeoPoint(latitude: fixLatLong(position.bounds!.northEast!.latitude), longitude: fixLatLong(position.bounds!.northEast!.longitude)),
    new GeoPoint(latitude: fixLatLong(position.bounds!.southEast.latitude), longitude: fixLatLong(position.bounds!.southEast.longitude)),
    new GeoPoint(latitude: fixLatLong(position.bounds!.southWest!.latitude), longitude: fixLatLong(position.bounds!.southWest!.longitude)),
    new GeoPoint(latitude: fixLatLong(position.bounds!.northWest.latitude), longitude: fixLatLong(position.bounds!.northWest.longitude)), //LinearRing must have same first and last point
  ];

  List<GeoSerie> geoSeries = [new GeoSerie(name: "name", type: GeoSerieType.polygon, geoPoints: geoPoints)];
  GeoJsonPolygon polygon = new GeoJsonPolygon(geoSeries: geoSeries);
  MultiPolygon searchPolygon = new MultiPolygon(polygons: [polygon], name: "polygon");

  var json = searchPolygon.toJson();

  double minTolerance = 0.001;
  double maxTolerance = 0.1;
  double minZoom = 3.5;
  double maxZoom = 18.4;
  double zoom = position.zoom == null ? 3.5 : position.zoom!;
  //zoom between 3.5 and 18.4
  double tolerance = exp(((zoom - minZoom) / (maxZoom - minZoom)))* (-1) * (maxTolerance - minTolerance) + maxTolerance;

  print("tolerance = " + tolerance.toString());


  final response = await http.post(
    Uri.parse(API_URL + "/councils/search/polygon?simplify_tolerance=${tolerance}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json,
  );

  if (response.statusCode == 200) {
    return Council.parseCouncilList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode}  http response = ${response.body}";
}

//get phootlocations for a council
Future<List<PhotoLocation>> getCouncilPhotoLocations(ObjectId council_id) async {
  final response = await http.get(Uri.parse(API_URL + "/councils/photolocations?council_id=${council_id.toString()}"));

  if (response.statusCode == 200) {
    return PhotoLocation.parsePhotoLocationList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

// --------------------------------
//  COMMUNITIES
// --------------------------------
/**
 * Useful as communities can contain complex boundaries,
 * and pulling all of them will be VERRRRRRRRRY SLOW
 */
Future<List<Community>> peekCommmunities() async {
  final response = await http.get(Uri.parse(API_URL + "/communities/peek"));

  if (response.statusCode == 200) {
    return Community.parseCommunityList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//get a community by id
Future<Community> getCommunity(ObjectId community_id) async {
  final response = await http.get(Uri.parse(API_URL + "/communities/${community_id.toString()}"));

  if (response.statusCode == 200) {
    return Community.fromJson(jsonDecode(response.body));
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//get community PhotoLocations
Future<List<PhotoLocation>> getCommunityLocations(ObjectId community_id) async {
  final response = await http.get(Uri.parse(API_URL + "/communities/locations?community_id=${community_id.toString()}"));

  if (response.statusCode == 200) {
    return PhotoLocation.parsePhotoLocationList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//search for community by term
Future<List<Community>> searchForCommunityBySearchTerm(String search_term) async {
  final response = await http.get(Uri.parse(API_URL + "/communities/search?search_term=$search_term"));

  if (response.statusCode == 200) {
    return Community.parseCommunityList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

//search for community by locaion
Future<List<Community>> searchForCommunityByLocation(PhotoLocation photoLocation) async {
  final response = await http.post(
    Uri.parse(API_URL + "/communities/search/location"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: photoLocation.toJson(),
  );

  if (response.statusCode == 200) {
    return Community.parseCommunityList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

Future<Community> addUserToCommunity(ObjectId communityId, User user) async {
  final response = await http.put(
    Uri.parse(API_URL + "/communities/users/add?community_id=${communityId.toString()}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: user.toJson(),
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return Community.fromJson(parsed);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

Future<Community> addEventToCommunity(ObjectId communityId, Event event) async {
  final response = await http.put(
    Uri.parse(API_URL + "/communities/users/add?community_id=${communityId.toString()}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: event.toJson(),
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    return Community.fromJson(parsed);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}

Future<List<Report>> getAllReports() async {
  final response = await http.get(Uri.parse(API_URL + "/reports"));

  if (response.statusCode == 200) {
    return Report.parseReportList(response.body);
  }

  throw "HTTP Error Code: ${response.statusCode} http response = ${response.body}";
}
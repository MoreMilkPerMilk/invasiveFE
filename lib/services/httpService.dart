import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter/cupertino.dart';
import 'package:geojson/geojson.dart';
import 'package:http/http.dart' as http;
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';

const API_URL = 'http://invasivesys.uqcloud.net:80';

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

/// communicate with backend server to HTTP GET all photoLocation instances. // todo: refix this
Future<List<PhotoLocation>> getAllPhotoLocations() async {
  final response = await http.get(Uri.parse(API_URL + "/photolocations"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);

    var result = PhotoLocation.parsePhotoLocationList(response.body);
    // result.forEach((element) {
    //   log(element.toString());
    // });

    return result;
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// add location (will merge with pre-existing locations in the DB)
Future<bool> addPhotoLocation(PhotoLocation photoLocation) async {
  // final response = await http.post(
  //   Uri.parse(API_URL + "/photolocations/add"),
  //   headers: <String, String>{
  //     'Content-Type': 'application/json; charset=UTF-8',
  //   },
  //   body: location.toJson(),
  // );

  String photoPath = photoLocation.photoPath == null ? "" : photoLocation.photoPath;
  //ByteData bytes = await rootBundle.load(photoPath); // fixme: incomplete
  XFile photoFile = XFile(photoPath);
  // Image boy = Image.file(
  //   File(photoPath),
  // );
  // print("Bytes");
  // print(bytes);
  // var boits = bytes.getUint8(0);
  print(photoFile);
  print(photoFile.path);
  print("PATH");
  // Directory tempDir = await getTemporaryDirectory();
  // String tempPath = tempDir.path;
  //photoLocation.photo.path = tempPath;
  //print(photoLocation.photo.readAsString());
  //print(photoLocation.photo.path); // fixme: appears to be null path?
  // convert Xfile photo to Image
  //final imageBytes = await File(photoLocation.photo.path).readAsBytes();
  //photoLocation.photo.saveTo(tempPath);

  final imageBytes = await photoFile.readAsBytes();
  print("Successfully converted image to bytes...");
  //final Image photoImage = img.decodeImage(bytes) as Image;

  final response = await http.post(
      Uri.parse(API_URL + "/photolocations/add?"
          "_id=${ObjectId()}&"
          "location=${GeoJsonPoint(geoPoint: photoLocation.location)}&"),
      headers: <String, String>{
        'Content-Type': 'multipart/form-data; boundary="&"',
      },
      body: "&" + base64Encode(imageBytes) + "&"
  );

  print(response.body);
  //print(photoLocation.toJson());

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode}";
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

  print(response.body);
  print(location.toJson());

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

// --------------------------------
//  USERS
// --------------------------------

/// communicate with backend server to HTTP GET all users.
Future<List<User>> getAllUsers() async {
  final response = await http.get(Uri.parse(API_URL + "/users"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);
    var result = User.parseUserList(response.body);
    log("result = " + result.toString());
    result.forEach((element) {
      log(element.toString());
    });
    return result;
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// communicate with backend server to HTTP GET a specific user.
Future<User> getUserById(int personId) async {
  final response = await http.get(
      Uri.parse(API_URL + "/users/$personId"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);

    var result = User.fromJson(jsonDecode(response.body));
    log(result.toString());
    return result;

    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// add User
Future<bool> addUser(User user) async {
  log("addUser");
  log(API_URL + "/users/create");
  final response = await http.post(
    Uri.parse(API_URL + "/users/create"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: user.toJson(),
  ).timeout(const Duration(seconds: 4)); //timeout for testing
  log("after res");

  log("add user response = " + response.statusCode.toString() + " " + response.body.toString());
  log("response = " + response.toString());

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// delete User
Future<bool> deleteUser(int personId) async {
  final response = await http.delete(
      Uri.parse(API_URL + "/users/delete?person_id=$personId"),
  );

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// add identification
// Future<bool> addWeedToUser(int personId, WeedInstance weed) async {
//   final response = await http.put(
//     Uri.parse(API_URL + "/users/add_identification?person_id=$personId"),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: weed.toJson(),
//   );
//
//   if (response.statusCode == 200) {
//     return true;
//   }
//   throw "HTTP Error Code: ${response.statusCode}";
// }

// --------------------------------
//  SPECIES
// --------------------------------

Future<List<Species>> getAllSpecies() async {
  final response = await http.get(Uri.parse(API_URL + "/species"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);
    var result = Species.parseSpeciesList(response.body);
    result.forEach((element) {
      log(element.toString());
    });
    return result;
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

Future<Species> getSpeciesById(int speciesID) async {
  final response = await http.get(
      Uri.parse(API_URL + "/species/?species_id=$speciesID"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);
    var result = Species.fromJson(jsonDecode(response.body));
    log(result.toString());
    return result;
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

// --------------------------------
//  Councils
// --------------------------------


// --------------------------------
//  WEEDS
// --------------------------------

//no more weedinstance class can remove

// Future<List<WeedInstance>> getAllWeeds() async {
//   final response = await http.get(Uri.parse(API_URL + "/weeds"));
//   if (response.statusCode == 200) {
//     var result = WeedInstance.parseWeedInstanceList(response.body);
//     result.forEach((element) {
//       log(element.toString());
//     });
//     return result;
//   }
//   throw "HTTP Error Code: ${response.statusCode}";
// }

// todo: refactor this
// Future<bool> addWeed(WeedInstance weed) async {
//   String image = weed.image_filename == null ? "" : weed.image_filename!;
//   ByteData bytes = await rootBundle.load(image); // fixme: incomplete
//   final response = await http.post(
//     Uri.parse(API_URL + "/weeds/add?"
//         "weed_id=${ObjectId()}&"
//         "species_id=${weed.species_id}&"
//         "discovery_date=${weed.discovery_date}&"
//         "removed=${weed.removed}&"
//         "removal_date=${weed.removed ? weed.removal_date : ""}&"
//         "replaced=${weed.replaced}&"
//         "replaced_species=${weed.replaced ? weed.replaced_species : ""}"),
//     headers: <String, String>{
//       'Content-Type': 'multipart/form-data; boundary="&"',
//     },
//     body: "&" + image + "&"
//   );
//
//   if (response.statusCode == 200) {
//     return true;
//   }
//   throw "HTTP Error Code: ${response.statusCode}";
// }

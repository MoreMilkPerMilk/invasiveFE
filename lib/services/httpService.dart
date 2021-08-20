import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/Location.dart';
import 'package:invasive_fe/models/WeedInstance.dart';

var API_URL = 'http://invasivesys.uqcloud.net:80';

// --------------------------------
//  LOCATIONS
// --------------------------------

/// communicate with backend server to HTTP GET all weed instances.
Future<List<Location>> getAllLocations() async {
  final response = await http.get(Uri.parse(API_URL + "/locations"));

  if (response.statusCode == 200) {
    // log(response.body);
    // var result = await compute(User.parseUserList, response.body);
    var result = Location.parseLocationList(response.body);
    result.forEach((element) {
      log(element.toString());
    });

    return result;
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  } else {
    return [];
  }
}

/// add location
Future<bool> addLocation(Location location) async {

  final response = await http.post(
    Uri.parse(API_URL + "/locations/add"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: location.toJson(),
  );

  print(response.body);
  print(location.toJson());

  if (response.statusCode == 200) {
    return true;
  } else{
    return false;
  }
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
  final response = await http.get(Uri.parse(API_URL + "/users/?person_id=$personId"));

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
  final response = await http.get(Uri.parse(API_URL + "/species/?species_id=$speciesID"));

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


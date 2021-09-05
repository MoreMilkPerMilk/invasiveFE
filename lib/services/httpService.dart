import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/Location.dart';
import 'package:invasive_fe/models/WeedInstance.dart';

var API_URL = 'http://invasivesys.uqcloud.net:80';

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
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// add location (will merge with pre-existing locations in the DB)
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
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// delete location
Future<bool> deleteLocation(Location location) async {
  final response = await http.post(
    Uri.parse(API_URL + "/locations/delete"),
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
      Uri.parse(API_URL + "/users/?person_id=$personId"));

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
  final response = await http.post(
    Uri.parse(API_URL + "/users/add"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: user.toJson(),
  );

  print(response.body);
  print(user.toJson());

  if (response.statusCode == 200) {
    return true;
  }
  throw "HTTP Error Code: ${response.statusCode}";
}

/// delete User
Future<bool> deleteUser(int personId) async {
  final response = await http.post(
      Uri.parse(API_URL + "/users/delete?person_id=$personId"),
  );

  print(response.body);

  if (response.statusCode == 200) {
    return true;
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


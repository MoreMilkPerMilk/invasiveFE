import 'dart:convert';

import 'package:flutter/services.dart';

class WeedInstance {
  String uuid;
  String image_url;
  // ByteData image_bytes;
  int species_id;
  String discovery_date;
  bool removed;
  String? removal_date;
  bool replaced;
  String? replaced_species;

  WeedInstance({
    required this.uuid,
    required this.image_url,
    required this.species_id,
    required this.discovery_date,
    required this.removed,
    this.removal_date,
    required this.replaced,
    this.replaced_species,
  });

  factory WeedInstance.fromJson(Map<String, dynamic> json) {
    return WeedInstance(
      uuid: json['uuid'],
      image_url: json['image_bytes'],
      species_id: json['species_id'],
      discovery_date: json['discovery_date'],
      removed: json['removed'],
      removal_date: json['removed_date'],
      replaced: json['replaced'],
      replaced_species: json['replaced_species']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "\t uuid: ${this.uuid}\n";
    output += "\t image_url: ${this.image_url}\n";
    output += "\t species_id: ${this.species_id}\n";
    output += "\t discovery_date: ${this.discovery_date}\n";
    output += "\t removed: ${this.removed}\n";
    if (this.removed) {
      output += "\t removal_date: ${this.removal_date}\n";
    }
    if (this.replaced) {
      output += "\t replaced_species: ${this.replaced_species}\n";
    }
    return output;
  }

  /// Parse a list of WeedInstances in JSON format
  static List<WeedInstance> parseWeedInstanceList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<WeedInstance>((json) => WeedInstance.fromJson(json)).toList();
  }

}

class User {
  int person_id;
  String first_name;
  String last_name;
  String date_joined;
  int count_identified;
  List<WeedInstance> previous_tags;

  User({
    required this.person_id,
    required this.first_name,
    required this.last_name,
    required this.date_joined,
    required this.count_identified,
    required this.previous_tags,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<WeedInstance> previous_tags = [];
    json['previous_tags'].forEach((element) {
      previous_tags.add(WeedInstance.fromJson(element));
    });

    return User(
      person_id: json['person_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      date_joined: json['date_joined'],
      count_identified: json['count_identified'],
      previous_tags: previous_tags,
      // previous_tags: json['previous_tags'],
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.person_id}\n";
    output += "first: ${this.first_name}\n";
    output += "name: ${this.last_name}\n";
    output += "date_joined: ${this.date_joined}\n";
    output += "count_identified: ${this.count_identified}\n";

    output += "previous_tags:\n";
    int i = 0;
    this.previous_tags.forEach((element) {
      output += "$i:";
      output += "\t $element";
      i++;
    });

    return output;
  }

  /// Parse a list of Users in JSON format
  static List<User> parseUserList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
}

class Location {
  String name;
  double lat;
  double long;
  List<WeedInstance> weeds_present;

  Location({
    required this.name,
    required this.lat,
    required this.long,
    required this.weeds_present,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    List<WeedInstance> weeds_present = [];
    json['weeds_present'].forEach((element) {
      weeds_present.add(WeedInstance.fromJson(element));
    });

    return Location(
      name: json['name'],
      lat: json['lat'],
      long: json['long'],
      weeds_present: weeds_present,
    );
  }

  @override
  String toString() {
    var output = "";
    output += "name: ${this.name}\n";
    output += "lat: ${this.lat}\n";
    output += "long: ${this.long}\n";

    output += "weeds_present:\n";
    int i = 0;
    weeds_present.forEach((element) {
      output += "$i:";
      output += "\t $element";
      i++;
    });

    return output;
  }


  /// Parse a list of Locations in JSON format
  static List<Location> parseLocationList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Location>((json) => Location.fromJson(json)).toList();
  }
}


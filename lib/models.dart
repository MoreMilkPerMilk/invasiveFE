import 'dart:convert';

import 'package:flutter/services.dart';

class WeedInstance {
  String uuid;
  ByteData image_bytes;
  int species_id;
  String discovery_date;
  bool removed;
  String? removal_date;
  bool replaced;
  String? replaced_species;

  WeedInstance({
    required this.uuid,
    required this.image_bytes,
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
      image_bytes: json['image_bytes'],
      species_id: json['species_id'],
      discovery_date: json['discovery_date'],
      removed: json['removed'],
      removal_date: json['removed_date'],
      replaced: json['replaced'],
      replaced_species: json['replaced_species']
    );
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
  List<dynamic> previous_tags;

  User({
    required this.person_id,
    required this.first_name,
    required this.last_name,
    required this.date_joined,
    required this.count_identified,
    required this.previous_tags,
  });

  @override
  String toString() {
    return "${this.person_id}, ${this.first_name}, ${this.count_identified}";
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      person_id: json['person_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      date_joined: json['date_joined'],
      count_identified: json['count_identified'],
      // previous_tags: WeedInstance.parseWeedInstanceList(json['previous_tags']),
      previous_tags: json['previous_tags'],
    );
  }

  /// Parse a list of WeedInstances in JSON format
  static List<User> parseUserList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
}


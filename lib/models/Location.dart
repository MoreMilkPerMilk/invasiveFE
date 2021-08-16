import 'dart:convert';

import 'WeedInstance.dart';

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
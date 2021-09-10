import 'dart:convert';

import 'package:objectid/objectid.dart';

import 'WeedInstance.dart';

class Location {
  ObjectId id;
  String name;
  double lat;
  double long;
  List<WeedInstance> weeds_present;

  Location({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.weeds_present,
  });

  String toJson() {
    List<String> weedsPresentJson = [];
    weeds_present.forEach((element) {
      weedsPresentJson.add(element.toJson());
    });

    List<double> coords = [lat, long];
    Map<String, dynamic> point = {};
    point['type'] = "Point";
    point['coordinates'] = coords;


    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      'name': name,
      'point': point,
      'weeds_present': weedsPresentJson,
    });
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    List<WeedInstance> weeds_present = [];
    json['weeds_present'].forEach((element) {
      weeds_present.add(WeedInstance.fromJson(element));
    });

    return Location(
      id: ObjectId.fromHexString(json['_id']),
      name: json['name'],
      lat: json['point']['coordinates'][0],
      long: json['point']['coordinates'][1],
      weeds_present: weeds_present,
    );
  }

  @override
  String toString() {
    var output = "";
    output += "_id: ${this.id}\n";
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
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:objectid/objectid.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

import 'WeedInstance.dart';

class PhotoLocation {
  ObjectId id;
  String name;
  Image photo;
  GeoPoint location;
  List<WeedInstance> weeds_present;

  PhotoLocation({
    required this.id,
    required this.name,
    required this.photo,
    required this.location,
    required this.weeds_present,
  });

  String toJson() {

    // get weeds json data
    List<String> weedsPresentJson = [];
    weeds_present.forEach((element) {
      weedsPresentJson.add(element.toJson());
    });

    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      'name': name,
      'point': GeoJsonPoint(geoPoint: location),
      'weeds_present': weedsPresentJson,
    });
  }

  factory PhotoLocation.fromJson(Map<String, dynamic> json, Image photo) {
    List<WeedInstance> weeds_present = [];
    json['weeds_present'].forEach((element) {
      weeds_present.add(WeedInstance.fromJson(element));
    });

    return PhotoLocation(
      id: ObjectId.fromHexString(json['_id']),
      name: json['name'],
      photo: photo,
      location: json['location'],
      weeds_present: weeds_present,
    );
  }

  @override
  String toString() {
    var output = "";
    output += "_id: ${this.id}\n";
    output += "name: ${this.name}\n";
    output += "point: ${this.location.toString()}\n";
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
  static List<PhotoLocation> parsePhotoLocationList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PhotoLocation>((json) => PhotoLocation.fromJson(json, img)).toList();
  }
}
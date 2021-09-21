import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:objectid/objectid.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

import 'WeedInstance.dart';

class PhotoLocation {
  ObjectId id;
  XFile photo;
  GeoPoint location;
  List<WeedInstance> weeds_present;

  PhotoLocation({
    required this.id,
    required this.photo,
    required this.location,
    required this.weeds_present
  });


  String toJson() { // may be redundant with api call structure

    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      'point': GeoJsonPoint(geoPoint: location),
    });
  }

  factory PhotoLocation.fromJson(Map<String, dynamic> json, XFile photo) {
    List<WeedInstance> weeds_present = [];
    json['weeds_present'].forEach((element) {
      weeds_present.add(WeedInstance.fromJson(element));
    });

    return PhotoLocation(
      id: ObjectId.fromHexString(json['_id']),
      photo: photo,
      location: json['location'],
      weeds_present: weeds_present,
    );
  }

  @override
  String toString() {
    var output = "";
    output += "_id: ${this.id}\n";
    output += "point: ${this.location.toString()}\n";
    return output;
  }

  /// Parse a list of Locations in JSON format todo: refactor this
  static Future<List<PhotoLocation>> parsePhotoLocationList(String responseBody) async {
    ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
    Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
    XFile xFile = XFile.fromData(imgUint8List);
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PhotoLocation>((json) => PhotoLocation.fromJson(json, xFile)).toList();
  }
}
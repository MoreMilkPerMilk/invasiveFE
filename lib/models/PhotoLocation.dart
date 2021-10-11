import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:objectid/objectid.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

class PhotoLocation {
  ObjectId id;
  File photo; //for app use
  String image_filename; //from db to load as XFile photo
  GeoJsonPoint location;

  PhotoLocation({
    required this.id,
    required this.photo,
    required this.image_filename,
    required this.location
  });


  String toJson() { // may be redundant with api call structure
    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      // 'point': '{"type":"Point","coordinates":' + location.geoPoint.toGeoJsonCoordinatesString() + '}',
      'point': {"type":"Point", "coordinates": [location.geoPoint.latitude, location.geoPoint.longitude]},
      'image_filename': image_filename
    });
  }

  factory PhotoLocation.fromJson(Map<String, dynamic> json) { //removed second arg - photo
    // ByteData imgBytes = rootBundle.load(json['image_filename']) as ByteData;
    // Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
    // XFile xFile = XFile.fromData(imgUint8List);
    log("photolocation fromJson "   + json.toString());
    log(json['_id'].toString());
    return PhotoLocation(
      id: ObjectId.fromHexString(json['_id']),
      photo: new File(""), //ignore
      location: json['location'],
      image_filename: json['image_filename'],
    );
  }

  @override
  String toString() {
    var output = "";
    output += "_id: ${this.id}\n";
    output += "point: ${this.location.toString()}\n";
    output += "image_filename: ${this.image_filename}\n";
    return output;
  }

  /// Parse a list of councils in JSON format
  static List<PhotoLocation> parsePhotoLocationList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PhotoLocation>((json) => PhotoLocation.fromJson(json)).toList();
  }
}

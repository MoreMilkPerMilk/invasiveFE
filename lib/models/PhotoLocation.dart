import 'dart:convert';
import 'dart:io';
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
  GeoPoint location;

  PhotoLocation({
    required this.id,
    required this.photo,
    required this.image_filename,
    required this.location
  });


  String toJson() { // may be redundant with api call structure

    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      'point': GeoJsonPoint(geoPoint: location),
      'image_filename': image_filename
    });
  }

  factory PhotoLocation.fromJson(Map<String, dynamic> json) { //removed second arg - photo
    // ByteData imgBytes = rootBundle.load(json['image_filename']) as ByteData;
    // Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
    // XFile xFile = XFile.fromData(imgUint8List);
    return PhotoLocation(
      id: ObjectId.fromHexString(json['_id']),
      // photo: new XFile("assets/placeholder.png"),
      photo: new File(""), //ignore
      location: json['location'],
      image_filename: json['image_filenplaceholderame'],
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

  /// Parse a list of Locations in JSON format todo: refactor this
  static Future<List<PhotoLocation>> parsePhotoLocationList(String responseBody) async {
    // ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
    // Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
    // XFile xFile = XFile.fromData(imgUint8List);
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PhotoLocation>((json) => PhotoLocation.fromJson(json)).toList();
  }
}

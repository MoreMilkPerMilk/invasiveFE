import 'dart:convert';
import 'dart:developer';
import 'package:image/image.dart';
import 'package:indent/indent.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:geojson/geojson.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:objectid/objectid.dart';

//models

class Report {
  ObjectId id;
  String name;
  int species_id;
  String status;
  List<PhotoLocation> photoLocations;
  String notes;
  GeoJsonMultiPolygon polygon;

  Report({
    required this.id,
    required this.species_id,
    required this.name,
    required this.status,
    required this.photoLocations,
    required this.notes,
    required this.polygon
  });

  String toJson() {

    // get photoLocations json data
    List<String> photoLocationsJSON = [];
    photoLocations.forEach((element) {
      photoLocationsJSON.add(element.toJson());
    });

    return jsonEncode(<String, dynamic>{
      '_id': id,
      'species_id': species_id,
      'name': name,
      'status': status,
      'photo_locations': photoLocationsJSON,
      'notes': notes,
      'polygon': polygon,
    });
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    List<PhotoLocation> photo_locations = [];

    log(json.toString());
    json['locations'].forEach((element) {
      photo_locations.add(PhotoLocation.fromJson(element));
    });

    return Report(
      id: ObjectId.fromHexString(json['_id']),
      species_id: int.parse(json['species_id']),
      name: json['name'],
      status: json['status'],
      photoLocations: photo_locations,
      notes: json['notes'],
      polygon: json['polygon']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.id}\n";
    output += "species_id: ${this.species_id}\n";
    output += "name: ${this.name}\n";
    output += "status: ${this.status}\n";
    output += "notes: ${this.notes}\n";
    int i = 0;
    this.photoLocations.forEach((element) {
      output += "$i:\n";
      output += "$element".indent(4);
      i++;
    });

    return output;
  }

  /// Parse a list of reports in JSON format
  static List<Report> parseReportList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Report>((json) => Report.fromJson(json)).toList();
  }
}
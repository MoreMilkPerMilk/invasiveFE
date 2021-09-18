import 'dart:convert';
import 'package:image/image.dart';
import 'package:indent/indent.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:geojson/geojson.dart';
import 'WeedInstance.dart';

class Report {
  int report_id;
  WeedInstance species;
  String name;
  String status;
  List<PhotoLocation> photoLocations;
  String notes;
  GeoJsonMultiPolygon polygon;

  Report({
    required this.report_id,
    required this.species,
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
      'report_id': report_id,
      'species': species,
      'name': name,
      'status': status,
      'photo_locations': photoLocationsJSON,
      'notes': notes,
      'polygon': polygon,
    });
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    List<WeedInstance> previous_tags = [];
    json['previous_tags'].forEach((element) {
      previous_tags.add(WeedInstance.fromJson(element));
    });

    return Report(
      report_id: json['report_id'],
      species: json['species'],
      name: json['name'],
      status: json['status'],
      photoLocations: json['photo_locations'],
      notes: json['notes'],
      polygon: json['polygon']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.report_id}\n";
    output += "species: ${this.species}\n";
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
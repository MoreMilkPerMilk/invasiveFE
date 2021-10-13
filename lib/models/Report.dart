import 'dart:convert';
import 'dart:developer';
import 'package:image/image.dart';
import 'package:indent/indent.dart';
import 'package:invasive_fe/models/MultiPolygon.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:geojson/geojson.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:objectid/objectid.dart';

//models

class Report {
  ObjectId id;
  String name;
  int species_id;
  String status;  // open vs closed
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
    print(photoLocationsJSON);

    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      'species_id': species_id.toString(),
      'name': name,
      'status': status,
      'locations': photoLocationsJSON,
      'notes': notes
    });
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    List<PhotoLocation> photo_locations = [];

    //double pad -> so [[[[152, 25], []]]]
    // if (json['polygon'] != null) {
    //   List<List<List<dynamic>>> tmp1 = [];
    //   tmp1.add(new List.from(json['polygon']['coordinates']));
    //   List<List<List<List<dynamic>>>> tmp2 = [];
    //   tmp2.add(new List.from(tmp1));
    //
    //   json['polygon']['coordinates'] = tmp2;
    // }
    //
    // // log(json.toString());
    // json['locations'].forEach((element) {
    //   photo_locations.add(PhotoLocation.fromJson(element));
    // });
    //
    // log("multipolygon");
    // log(json['polygon'].toString());
    // log("multipolygon");

    return Report(
      id: ObjectId.fromHexString(json['_id']),
      species_id: int.parse(json['species_id']),
      name: json['name'],
      status: json['status'],
      photoLocations: photo_locations,
      notes: json['notes'],
      polygon: json['polygon'] == null ?
        MultiPolygon(polygons: [], name: "polygon") :
        MultiPolygon.fromJson(json['polygon']),
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

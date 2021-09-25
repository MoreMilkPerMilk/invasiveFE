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
import 'Event.dart';
import 'User.dart';

class Council {
  ObjectId id;
  String name;
  List<String> species_occuring;
  MultiPolygon boundary;
  int lga_code;
  String abbreviated_name;
  double area_sqkm;


  Council({
    required this.id,
    required this.name,
    required this.species_occuring,
    required this.boundary,
    required this.lga_code,
    required this.abbreviated_name,
    required this.area_sqkm
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      '_id': id,
      'name': name,
      'boundary': boundary.toGeoJsonMultiPolygon().serializeFeature(),
      'species_occuring': species_occuring,
      'lga_code': lga_code,
      'abbreviated_name': abbreviated_name,
      'area_sqkm': area_sqkm
    });
  }

  factory Council.fromJson(Map<String, dynamic> json) {
    // log(json.toString());

    return Council(
        id: ObjectId.fromHexString(json['_id']),
        name: json['name'],
        boundary: json['boundary'] == null ?
                      MultiPolygon(polygons: [], name: "polygon") :
                            MultiPolygon.fromJson(json['boundary']),
        species_occuring: (json['species_occuring'].runtimeType.toString() == "List<String>") ? ([...json['species_occuring']]) : ([json['species_occuring']].cast<String>()),
        lga_code: json['lga_code'],
        abbreviated_name: json['abbreviated_name'],
        area_sqkm: json['area_sqkm']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.id}\n";
    output += "name: ${this.name}\n";

    return output;
  }

  /// Parse a list of councils in JSON format
  static List<Council> parseCouncilList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Council>((json) => Council.fromJson(json)).toList();
  }
}
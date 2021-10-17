import 'dart:convert';
import 'dart:developer';
import 'package:image/image.dart';
import 'package:indent/indent.dart';
import 'package:invasive_fe/models/MultiPolygon.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:geojson/geojson.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:objectid/objectid.dart';

class Landcare {
  ObjectId id;
  MultiPolygon boundary;
  String state;
  String area_desc;
  int nrm_id;
  String nlp_mu;
  double shape_area;
  double shape_len;

  Landcare({
    required this.id,
    required this.boundary,
    required this.state,
    required this.area_desc,
    required this.nrm_id,
    required this.nlp_mu,
    required this.shape_area,
    required this.shape_len,
  });

  factory Landcare.fromJson(Map<String, dynamic> json) {
    // log(json.toString());
    return Landcare(
      id: ObjectId.fromHexString(json['_id']),
      state: json['state'],
      boundary: json['boundary'] == null
          ? MultiPolygon(polygons: [], name: "polygon")
          : MultiPolygon.fromJson(json['boundary']),
      area_desc: json['area_desc'],
      nrm_id: json['nrm_id'],
      nlp_mu: json['nlp_mu'],
      shape_area: json['shape_area'],
      shape_len: json['shape_len']
    );
  }

  @override
  String toString() {
    var output = "Landcare";
    output += "id: ${this.id}\n";
    output += "name: ${this.state}\n";

    return output;
  }

  /// Parse a list of Landcares in JSON format
  static List<Landcare> parseLandcareList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Landcare>((json) => Landcare.fromJson(json)).toList();
  }

  @override
  // TODO: implement hashCode
  int get hashCode => this.id.toString().hashCode;
}

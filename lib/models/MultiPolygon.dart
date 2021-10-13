import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:geojson/geojson.dart';


import 'package:geopoint/geopoint.dart';

/**
 * Wrapper for GeoJsonMultiPolygon to
 * fetch from DB etc.
 */
class MultiPolygon extends GeoJsonMultiPolygon {
  MultiPolygon({required List<GeoJsonPolygon>? polygons, required name}) :
      super(polygons: polygons, name: name);

  factory MultiPolygon.fromJson(Map<String, dynamic> json) {
    List<List<List<List<double>>>> coordinates = [];

    // log(json['coordinates'].toString());
    try {
      coordinates = List<List<List<List<double>>>>.from(json["coordinates"].map(
              (x) =>
          List<List<List<double>>>.from(
              x.map((x) =>
              List<List<double>>.from(
                  x.map((x) =>
                  List<double>.from(x.map((x) => x.toDouble()))))))));
    } catch (e) {
      log("exception occured");
      log(e.toString());
      log(json.toString());
      log(json['coordinates'].toString());
    }

    //construct MuliPolygon from coordinates
    List<GeoJsonPolygon> polygons = [];
    coordinates.forEach((coordinatesPolygon) {
      coordinatesPolygon.forEach((element) {
        GeoSerie geoSerie = new GeoSerie(name: "MultiPolygon GeoSeries", type: GeoSerieType.polygon,
            geoPoints: List<GeoPoint>.from(element.map(
                    (x) => GeoPoint(latitude: x.last, longitude: x.first)
            )));

        List<GeoSerie> geoSeries = [geoSerie];
        polygons.add(new GeoJsonPolygon(geoSeries: geoSeries));
      });
    });

    log(polygons.toString());

    return new MultiPolygon(polygons: polygons, name: "MultiPolygon");
  }

  GeoJsonMultiPolygon toGeoJsonMultiPolygon() {
    return new GeoJsonMultiPolygon(polygons: this.polygons, name: this.name);
  }

  String toJson() {
    var coords = List<List<List<double>>>.from(this.polygons.first.geoSeries.map((geoSerie) {
        print("geoserie");
        print(geoSerie);
        List<List<double>> pts = [];
        geoSerie.geoPoints.forEach((geoPoint) {
          pts.add([geoPoint.longitude, geoPoint.latitude]);
        });
        return pts;
        // var x = List<double>.from(geoSerie.geoPoints.map((GeoPoint geoPoint) {
        //   print("geopoint");
        //   print(geoPoint);
        //   return [geoPoint.longitude, geoPoint.latitude];
        // }));
        // print(x);
      }));

    print("coords = ");
    print(coords);

      return jsonEncode(<String, dynamic>{
        'type': "MultiPolygon",
        'coordinates': coords
      });
  }
}

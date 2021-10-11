import 'dart:convert';
import 'package:indent/indent.dart';
import 'package:objectid/objectid.dart';

//models
import 'Report.dart';

class User {
  // int person_id;
  ObjectId id;
  String first_name;
  String last_name;
  String date_joined;
  List<Report> reports;

  User({
    required this.id,
    required this.first_name,
    required this.last_name,
    required this.date_joined,
    required this.reports,
  });

  String toJson() {
    List<String> reportsJson = [];
    this.reports.forEach((element) {
      reportsJson.add(element.toJson());
    });

    return jsonEncode(<String, dynamic>{
      '_id': id.toString(),
      'first_name': first_name,
      'last_name': last_name,
      'date_joined': date_joined,
      'reports': reportsJson,
    });
  }

  factory User.fromJson(Map<String, dynamic> json) {
    List<Report> reports = [];
    json['reports'].forEach((element) {
      reports.add(Report.fromJson(element));
    });

    return User(
      id: ObjectId.fromHexString(json['_id']),
      first_name: json['first_name'],
      last_name: json['last_name'],
      date_joined: json['date_joined'],
      reports: reports
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.id}\n";
    output += "first_name: ${this.first_name}\n";
    output += "last_name: ${this.last_name}\n";
    output += "date_joined: ${this.date_joined}\n";
    output += "reports:\n";
    int i = 0;
    this.reports.forEach((element) {
      output += "$i:\n";
      output += "$element".indent(4);
      i++;
    });

    return output;
  }

  /// Parse a list of Users in JSON format
  static List<User> parseUserList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
}
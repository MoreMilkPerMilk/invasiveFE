import 'dart:convert';
import 'dart:developer';
import 'package:image/image.dart';
import 'package:indent/indent.dart';
import 'package:geojson/geojson.dart';
import 'package:invasive_fe/widgets/maps.dart';
import 'package:objectid/objectid.dart';

// import 'package:invasive_fe/models/PhotoLocation.dart';

//models
import 'Community.dart';
import 'Council.dart';
import 'PhotoLocation.dart';
import 'User.dart';

class Event {
  ObjectId id;
  String name;
  List<User> users;
  String description;
  Community community;
  Council council;

  Event({
    required this.id,
    required this.name,
    required this.users,
    required this.description,
    required this.community,
    required this.council
  });

  String toJson() {
    List<String> userListJSON = [];
    users.forEach((element) {
      userListJSON.add(element.toJson());
    });

    return jsonEncode(<String, dynamic>{
      '_id': id,
      'name': name,
      'users': userListJSON,
      'description': description,
      'community': community.toJson(),
      'council': council.toJson()
    });
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    List<User> users = [];

    log(json.toString());
    json['users'].forEach((element) {
      users.add(User.fromJson(element));
    });

    return Event(
        id: ObjectId.fromHexString(json['_id']),
        name: json['name'],
        users: users,
        description: json['description'],
        community: Community.fromJson(json['community']),
        council: Council.fromJson(json['council'])
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.id}\n";
    output += "name: ${this.name}\n";
    output += "description: ${this.description}\n";
    output += "community: ${this.community.toString()}\n";
    output += "council: ${this.council.toString()}\n";

    int i = 0;
    this.users.forEach((element) {
      output += "$i:\n";
      output += "$element".indent(4);
      i++;
    });

    return output;
  }

  /// Parse a list of reports in JSON format
  static List<Event> parseEventList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Event>((json) => Event.fromJson(json)).toList();
  }
}
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

class Community {
  ObjectId id;
  String name;
  List<Event> events;
  List<User> members;
  MultiPolygon boundary;
  List<String> suburbs;
  List<String> councils;

  Community({
    required this.id,
    required this.name,
    required this.events,
    required this.members,
    required this.boundary,
    required this.suburbs,
    required this.councils
  });

  String toJson() {
    //convert to json
    List<String> eventsListJSON = [];
    List<String> membersListJSON = [];

    members.forEach((element) {
      membersListJSON.add(element.toJson());
    });

    events.forEach((element) {
      eventsListJSON.add(element.toJson());
    });

    return jsonEncode(<String, dynamic>{
      '_id': id,
      'name': name,
      'events': eventsListJSON,
      'members': membersListJSON,
      'boundary': boundary.serializeFeature(),
      'suburbs': suburbs,
      'councils': councils
    });
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    List<Event> events = [];
    List<User> members = [];

    // log(json.toString());
    json['events'].forEach((element) {
      events.add(Event.fromJson(element));
    });

    json['members'].forEach((element) {
      members.add(User.fromJson(element));
    });

    return Community(
        id: ObjectId.fromHexString(json['_id']),
        name: json['name'],
        events: events,
        members: members,
        boundary: json['boundary'] == null ?
            MultiPolygon(polygons: [], name: "polygon") :
                MultiPolygon.fromJson(json['boundary']),
        suburbs: (json['suburbs'].runtimeType.toString() == "List<String>") ? ([...json['suburbs']]) : ([json['suburbs']].cast<String>()),
        councils: (json['councils'].runtimeType.toString() == "List<String>") ? ([...json['councils']]) : ([json['councils']].cast<String>()),
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.id}\n";
    output += "name: ${this.name}\n";
    int i = 0;
    this.events.forEach((element) {
      output += "$i:\n";
      output += "$element".indent(4);
      i++;
    });

    i = 0;
    this.members.forEach((element) {
      output += "$i:\n";
      output += "$element".indent(4);
      i++;
    });

    return output;
  }

  /// Parse a list of communities in JSON format
  static List<Community> parseCommunityList(String responseBody) {
    // log(responseBody);
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Community>((json) => Community.fromJson(json)).toList();
  }
}

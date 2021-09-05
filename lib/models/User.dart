import 'dart:convert';

import 'WeedInstance.dart';

class User {
  int person_id;
  String first_name;
  String last_name;
  String date_joined;
  int count_identified;
  List<WeedInstance> previous_tags;

  User({
    required this.person_id,
    required this.first_name,
    required this.last_name,
    required this.date_joined,
    required this.count_identified,
    required this.previous_tags,
  });

  String toJson() {
    List<String> previousTagsJson = [];
    this.previous_tags.forEach((element) {
      previousTagsJson.add(element.toJson());
    });

    return jsonEncode(<String, dynamic>{
      'person_id': person_id,
      'first_name': first_name,
      'last_name': last_name,
      'date_joined': date_joined,
      'count_identified': count_identified,
      'previous_tags': previousTagsJson,
    });
  }

  factory User.fromJson(Map<String, dynamic> json) {
    List<WeedInstance> previous_tags = [];
    json['previous_tags'].forEach((element) {
      previous_tags.add(WeedInstance.fromJson(element));
    });

    return User(
      person_id: json['person_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      date_joined: json['date_joined'],
      count_identified: json['count_identified'],
      previous_tags: previous_tags,
      // previous_tags: json['previous_tags'],
    );
  }

  @override
  String toString() {
    var output = "";
    output += "id: ${this.person_id}\n";
    output += "first: ${this.first_name}\n";
    output += "name: ${this.last_name}\n";
    output += "date_joined: ${this.date_joined}\n";
    output += "count_identified: ${this.count_identified}\n";

    output += "previous_tags:\n";
    int i = 0;
    this.previous_tags.forEach((element) {
      output += "$i:";
      output += "\t $element";
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
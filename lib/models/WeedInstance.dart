import 'dart:convert';

class WeedInstance {
  int species_id;
  String speciesName;
  String discovery_date;
  String info;

  WeedInstance({
    required this.species_id,
    required this.speciesName,
    required this.discovery_date,
    required this.info,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'species_id': species_id,
      'species_name': speciesName,
      'discovery_date': discovery_date,
      'info': info,
    });
  }

  factory WeedInstance.fromJson(Map<String, dynamic> json) {
    return WeedInstance(
        species_id: json['species_id'],
        speciesName: json['species_name'],
        discovery_date: json['discovery_date'],
        info: json['info']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "species_id: ${this.species_id}\n";
    output += "species_name: ${this.speciesName}\n";
    output += "discovery_date: ${this.discovery_date}\n";
    return output;
  }

  /// Parse a list of WeedInstances in JSON format
  static List<WeedInstance> parseWeedInstanceList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<WeedInstance>((json) => WeedInstance.fromJson(json)).toList();
  }

}
import 'dart:convert';

class WeedInstance {
  String uuid;
  String image_url;
  // ByteData image_bytes;
  int species_id;
  String discovery_date;
  bool removed;
  String? removal_date;
  bool replaced;
  String? replaced_species;

  WeedInstance({
    required this.uuid,
    required this.image_url,
    required this.species_id,
    required this.discovery_date,
    required this.removed,
    this.removal_date,
    required this.replaced,
    this.replaced_species,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'uuid': uuid,
      'image_url': image_url,
      'species_id': species_id,
      'discovery_date': discovery_date,
      'removed': removed,
      'removal_date': removal_date,
      'replaced': replaced,
      'replaced_species': replaced_species,
    });
  }

  factory WeedInstance.fromJson(Map<String, dynamic> json) {
    return WeedInstance(
        uuid: json['uuid'],
        image_url: json['image_bytes'],
        species_id: json['species_id'],
        discovery_date: json['discovery_date'],
        removed: json['removed'],
        removal_date: json['removed_date'],
        replaced: json['replaced'],
        replaced_species: json['replaced_species']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "\t uuid: ${this.uuid}\n";
    output += "\t image_url: ${this.image_url}\n";
    output += "\t species_id: ${this.species_id}\n";
    output += "\t discovery_date: ${this.discovery_date}\n";
    output += "\t removed: ${this.removed}\n";
    if (this.removed) {
      output += "\t removal_date: ${this.removal_date}\n";
    }
    if (this.replaced) {
      output += "\t replaced_species: ${this.replaced_species}\n";
    }
    return output;
  }

  /// Parse a list of WeedInstances in JSON format
  static List<WeedInstance> parseWeedInstanceList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<WeedInstance>((json) => WeedInstance.fromJson(json)).toList();
  }

}
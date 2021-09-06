import 'dart:convert';

class WeedInstance {
  int species_id;
  String discovery_date;
  bool removed;
  String? removal_date;
  bool replaced;
  String? replaced_species;
  String? image_filename;

  WeedInstance({
    required this.species_id,
    required this.discovery_date,
    required this.removed,
    this.removal_date,
    required this.replaced,
    this.replaced_species,
    this.image_filename,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'species_id': species_id,
      'discovery_date': discovery_date,
      'removed': removed,
      'removal_date': removal_date,
      'replaced': replaced,
      'replaced_species': replaced_species,
      'image_filename': image_filename,
    });
  }

  factory WeedInstance.fromJson(Map<String, dynamic> json) {
    return WeedInstance(
        species_id: json['species_id'],
        discovery_date: json['discovery_date'],
        removed: json['removed'],
        removal_date: json['removal_date'],
        replaced: json['replaced'],
        replaced_species: json['replaced_species'],
        image_filename: json['image_filename']
    );
  }

  @override
  String toString() {
    var output = "";
    output += "\t species_id: ${this.species_id}\n";
    output += "\t discovery_date: ${this.discovery_date}\n";
    output += "\t removed: ${this.removed}\n";
    if (this.removed) {
      output += "\t removal_date: ${this.removal_date}\n";
    }
    output += "\t replaced: ${this.replaced}\n";
    if (this.replaced) {
      output += "\t replaced_species: ${this.replaced_species}\n";
    }
    output += "\t image_url: ${this.image_filename != null ? this.image_filename : "None"}\n";
    return output;
  }

  /// Parse a list of WeedInstances in JSON format
  static List<WeedInstance> parseWeedInstanceList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<WeedInstance>((json) => WeedInstance.fromJson(json)).toList();
  }

}
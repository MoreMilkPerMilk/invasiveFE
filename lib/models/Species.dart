import 'dart:convert';
import 'package:string_extensions/string_extensions.dart';

class Species {
  int species_id;
  String name;
  String species;
  String growth_form;
  String? info;
  String family;
  bool native;
  List<String> flower_colour;
  List<String> flowering_time;
  List<String> leaf_arrangement;
  List<String> common_names;
  bool notifiable;
  List<String> control_methods;
  List<String> replacement_species;
  List<String> state_declaration;
  String council_declaration;

  Species({
    required this.species_id,
    required this.name,
    required this.species,
    required this.growth_form,
    this.info,
    required this.family,
    required this.native,
    required this.flower_colour,
    required this.flowering_time,
    required this.leaf_arrangement,
    required this.common_names,
    required this.notifiable,
    required this.control_methods,
    required this.replacement_species,
    required this.state_declaration,
    required this.council_declaration,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    String name = json['name']!;
    try {
      // sometimes this conversion throws an error, but most of the time it works
      name = name.toTitleCase()!;
    } catch (error) {}
    return Species(
        species_id: json['species_id'],
        name: name,
        species: json['species'],
        growth_form: json['growth_form'],
        info: json['info'],
        family: json['family'],
        native: json['native'],
        flower_colour: [...json['flower_colour']],
        flowering_time: (json['flowering_time'].runtimeType.toString() == "List<String>") ? ([...json['flowering_time']]) : ([json['flowering_time']].cast<String>()),
        leaf_arrangement: (json['leaf_arrangement'].runtimeType.toString() == "List<String>") ? ([...json['leaf_arrangement']]) : ([json['leaf_arrangement']].cast<String>()),
        common_names: (json['common_names'].runtimeType.toString() == "List<String>") ? ([...json['common_names']]) : ([json['common_names']].cast<String>()),
        control_methods: (json['control_methods'].runtimeType.toString() == "List<String>") ? ([...json['control_methods']]) : ([json['control_methods']].cast<String>()),
        replacement_species: (json['replacement_species'].runtimeType.toString() == "List<String>") ? ([...json['replacement_species']]) : ([json['replacement_species']].cast<String>()),
        state_declaration: (json['state_declaration'].runtimeType.toString() == "List<String>") ? ([...json['state_declaration']]) : ([json['state_declaration']].cast<String>()),
        notifiable: json['notifiable'],
        council_declaration: json['council_declaration'],
    );
  }

  @override
  String toString() {
    var output = "";
    output += "\t id: $species_id - $name";
    return output;
  }

  /// Parse a list of WeedInstances in JSON format
  static List<Species> parseSpeciesList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Species>((json) => Species.fromJson(json)).toList();
  }

}
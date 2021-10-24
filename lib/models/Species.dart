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
  late String state_declaration;
  late String council_declaration;
  late SpeciesSeverity severity;

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
    required List<String> state_declaration,
    required String council_declaration,
  }) {
    try {
      state_declaration.first = parseHyphens(state_declaration.first);
    } catch (castError) {
      state_declaration = [""];
    }
    this.state_declaration = state_declaration.first;
    this.council_declaration = parseHyphens(council_declaration);
    severity = getSeverity(state_declaration.first, council_declaration);
  }

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

/// for cleaning state & council declarations, where '-' is stored as 'â€'. currently unused
String parseHyphens(String str) {
  str = str.replaceFirst(RegExp(r'[^A-Za-z0-9().,-:; ]'), '-');
  return str.replaceAll(RegExp(r'[^A-Za-z0-9().,-:; ]'), '');
}

/// Species severity is primarily defined according to the state declaration category, where category 1 = low,
/// category 2 = med_low, ..., and category 5 = high.
/// Where a state category cannot be found, the council declaration is used, where class R = low, class C = med and
/// class E = high.
/// If neither a state nor council classification can be found, defaults to LOW.
enum SpeciesSeverity {
  LOW,
  MED_LOW,
  MED,
  MED_HIGH,
  HIGH
}

/// see @SpeciesSeverity
SpeciesSeverity getSeverity(String stateDecl, String councilDecl) {
  if (stateDecl.contains('5')) {
    return SpeciesSeverity.HIGH;
  } else if (stateDecl.contains('4')) {
    return SpeciesSeverity.MED_HIGH;
  } else if (stateDecl.contains('3')) {
    return SpeciesSeverity.MED;
  } else if (stateDecl.contains('2')) {
    return SpeciesSeverity.MED_LOW;
  } else if (stateDecl.contains('1')) {
    return SpeciesSeverity.LOW;
  } else if (councilDecl.contains('Class R')) {
    return SpeciesSeverity.LOW;
  } else if (councilDecl.contains('Class C')) {
    return SpeciesSeverity.MED;
  } else if (councilDecl.contains('Class E')) {
    return SpeciesSeverity.HIGH;
  } else {
    return SpeciesSeverity.LOW;
  }
}
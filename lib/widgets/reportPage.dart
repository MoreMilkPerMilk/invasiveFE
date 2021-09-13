import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/httpService.dart';

// ignore: must_be_immutable
class ReportPage extends StatelessWidget {

  WeedInstance weed;
  Species? species;
  late Future<List<Species>> speciesFuture;

  ReportPage({required this.weed}) : super() {
    speciesFuture = getAllSpecies();
    speciesFuture.then((List<Species> speciesList) {
      for (Species species in speciesList) {
        if (species.species_id == weed.species_id) {
          this.species = species;
          break;
        }
      }
      if (species == null) {
        throw Exception("Failed to find species with ID: ${weed.species_id}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
          future: speciesFuture, // only build once we have retrieved species data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                  children: [
                    CardWithHeader(
                        header: "PLANT INFO",
                        body: PlantInfoBox(
                            species: species!, weed: weed)),
                    CardWithHeader(
                        header: "WEEDS REPORTING",
                        body: Text("body")),
                    CardWithHeader(
                        header: "RESOURCES",
                        body: Text("body"))
                  ]
              );
            } else {
              return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()
              );
            }
          }
        )
    );
  }
}

class CardWithHeader extends StatelessWidget {

  final String header;
  final Widget body;
  // UI variables
  final double externalPadding = 10;
  final double internalPadding = 10;
  final double borderWidth = 2;

  CardWithHeader({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
        return Padding(
          // space around the card
          padding: EdgeInsets.only(
              top: externalPadding,
              left: externalPadding,
              right: externalPadding),
          child: Container(
            // expand cards to fill screen width
            width: double.infinity,
            child: Card(
                margin: EdgeInsets.zero,
                shape: Border.all(width: borderWidth),
                // card contents
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        // space around the header text
                        padding: EdgeInsets.all(internalPadding),
                        child: Text(header,
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                        ),
                      )
                    ),
                    Divider(
                      thickness: borderWidth,
                      height: 0,
                      color: Colors.black,
                    ),
                    Padding(
                        padding: EdgeInsets.all(internalPadding),
                        child: body
                    )
                  ],
                )
            ),
          )
        );
  }
}

class PlantInfoBox extends StatelessWidget {

  final Species species;
  final WeedInstance weed;
  // UI variables
  final TextStyle textStyle = GoogleFonts.openSans(
    fontSize: 11,
  );

  PlantInfoBox({required this.species, required this.weed}) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Common Name: " + species.name, style: textStyle),
                Text("Scientific Name: " + species.species, style: textStyle),
                Text("Family: " + species.family, style: textStyle),
                Text("Council Declaration: " + species.council_declaration, style: textStyle)
              ],
            )
        ),
        Expanded(
          flex: 3, // this image can use no more than 30% of the parent's width
          child: Image.network(weed.image_filename!)
        )
      ],
    );
  }
}
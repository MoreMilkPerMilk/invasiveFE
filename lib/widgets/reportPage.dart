import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:line_icons/line_icons.dart';

final TextStyle textStyle = GoogleFonts.openSans(
  fontSize: 11,
);

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
            future:
                speciesFuture, // only build once we have retrieved species data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(children: [
                  CardWithHeader(
                      header: "PLANT INFO",
                      body: PlantInfoBox(species: species!, weed: weed)),
                  CardWithHeader(
                      header: "WEEDS REPORTING", body: WeedsReportingBox()),
                  CardWithHeader(header: "RESOURCES", body: Text("body"))
                ]);
              } else {
                return Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
              }
            }));
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
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      )),
                  Divider(
                    thickness: borderWidth,
                    height: 0,
                    color: Colors.black,
                  ),
                  Padding(padding: EdgeInsets.all(internalPadding), child: body)
                ],
              )),
        ));
  }
}

class PlantInfoBox extends StatelessWidget {
  final Species species;
  final WeedInstance weed;

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
                Text("Council Declaration: " + species.council_declaration,
                    style: textStyle)
              ],
            )),
        Expanded(
            flex:
                3, // this image can use no more than 30% of the parent's width
            child: Image.network(weed.image_filename!))
      ],
    );
  }
}

class WeedsReportingBox extends StatelessWidget {

  WeedsReportingBox() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Some text about the report?", style: textStyle),
        ReportUpdateForm()
      ],
    );
  }
}

class ReportUpdateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReportUpdateFormState();
}

class _ReportUpdateFormState extends State {
  bool wrongAutomatedInformation = false;
  bool contactedByWeedsOfficer = false;
  String additionalComments = "";

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // this wrapper removes the default margin of the checkbox
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                      value: wrongAutomatedInformation,
                      onChanged: (value) {
                        setState(() {
                          wrongAutomatedInformation = value!;
                        });
                      }
                  ),
                ),
                Text("I think the automated identification is wrong.", style: textStyle)
              ],
            ),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                      value: contactedByWeedsOfficer,
                      onChanged: (value) {
                        setState(() {
                          contactedByWeedsOfficer = value!;
                        });
                      }
                  ),
                ),
                Text("I would like to be contacted by the weeds officer.", style: textStyle)
              ],
            ),
            Text("Additional comments:", style: textStyle),
            Row(
              children: [
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all()
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(6)
                          ),
                          maxLines: null, // grow forever
                          onChanged: (value) {
                            additionalComments = value;
                            print(additionalComments);
                          },
                        )
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Submit"),
                  )
                )
              ],
            )
          ]
        )
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:html_unescape/html_unescape.dart';

final TextStyle headingStyle = GoogleFonts.openSans(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.black
);

final double internalPadding = 10;
final double externalPadding = 10;

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
                      header: "Species Info",
                      body: PlantInfoBox(species: species!, weed: weed)),
                  CardWithHeader(
                      header: "Reporting", body: WeedsReportingBox()),
                  CardWithHeader(header: "RESOURCES", body: ResourcesBox())
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
  final double borderWidth = 2;

  CardWithHeader({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
        // space around the card
        padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16),
        child: Container(
          // expand cards to fill screen width
          width: double.infinity,
          child: Card(
                elevation: 10.0,
                shadowColor: Colors.black,
                color: Color.fromRGBO(220, 220, 220, 1),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                ),
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
                    Padding(padding: EdgeInsets.all(internalPadding), child: body)
                  ],
                )
            )
          ),
        );
  }
}

class PlantInfoBox extends StatelessWidget {
  final Species species;
  final WeedInstance weed;
  final TextStyle headingStyle = GoogleFonts.openSans(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.black
  );
  final TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 11,
      color: Colors.black
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
                HeadingColonBody("Common Name: ", species.name),
                HeadingColonBody("Scientific Name: ", species.species),
                HeadingColonBody("Family: ", species.family),
                HeadingColonBody("Council Declaration: ", HtmlUnescape().convert(species.council_declaration)), // fixme: doesn't fix the garble. i tried ~james
                HeadingColonBody("Environmental Impact: ", ""),
                SeverityBar(SeverityBar.HIGH)
              ]
            )
        ),
        Expanded(
            flex:
                3, // this image can use no more than 30% of the parent's width
            child: Image.network(weed.image_filename!))
      ],
    );
  }
}

class SeverityBar extends StatelessWidget {

  static const int LOW = 0;
  static const int MED = 1;
  static const int HIGH = 2;
  final int severity;

  SeverityBar(this.severity);

  @override
  Widget build(BuildContext context) {
      return Container(
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.black
            )
        ),
        child:
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: severity == LOW ? 1 : severity == MED ? 5 : 9,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15)
                          ),
                          color: severity == LOW ? Colors.yellow : severity == MED ? Colors.orange : Colors.red
                      ),
                    )
                  ),
                  Expanded(
                      flex: severity == LOW ? 9 : severity == MED ? 5 : 1,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                            color: Colors.white
                        ),
                      )
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("low"),
                    Text("med"),
                    Text("high")
                  ],
                ),
              )
            ],
          )
    );
  }
}

class HeadingColonBody extends RichText {

  final String heading;
  final String body;

  HeadingColonBody(this.heading, this.body) : super(
      text: TextSpan(
          style: GoogleFonts.openSans(
              fontSize: 11,
              color: Colors.black
          ),
          children: [
            TextSpan(
                text: heading,
                style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                )
            ),
            TextSpan(
                text: body,
            )
          ]
      )
  );
}

class WeedsReportingBox extends StatelessWidget {
  WeedsReportingBox() : super();
  final TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 11,
      color: Colors.black
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Some text about the report?", style: bodyStyle),
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
  TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 11,
      color: Colors.black
  );

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    }),
              ),
              Text("I think the automated identification is wrong.",
                  style: bodyStyle)
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
                    }),
              ),
              Text("I would like to be contacted by the weeds officer.",
                  style: bodyStyle)
            ],
          ),
          Text("Additional comments:", style: bodyStyle),
          Row(
            children: [
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: TextField(
                        decoration: InputDecoration(
                            isDense: true, contentPadding: EdgeInsets.all(6)),
                        maxLines: null, // grow forever
                        onChanged: (value) {
                          additionalComments = value;
                        },
                      ))),
              Padding(
                  padding: EdgeInsets.only(left: internalPadding),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Submit"),
                  ))
            ],
          )
        ]));
  }
}

class ResourcesBox extends StatelessWidget {
  ResourcesBox() : super();
  final TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 11,
      color: Colors.black
  );

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Information on this species", style: headingStyle),
            Text("<some info>", style: bodyStyle),
            Padding(padding: EdgeInsets.only(top: internalPadding)),
            Text("Information on managing this weed", style: headingStyle),
            Text("<some info>", style: bodyStyle),
            Padding(padding: EdgeInsets.only(top: internalPadding)),
            Text("Contact your local weeds officer or landcare group", style: headingStyle),
            Text("<some info>", style: bodyStyle),
          ],
        )
    );
  }
}

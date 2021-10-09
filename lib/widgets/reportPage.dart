import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
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
  Report report;
  Species? species;
  late Future<List<Species>> speciesFuture;

  ReportPage({required this.report}) : super() {
    speciesFuture = getAllSpecies();
    speciesFuture.then((List<Species> speciesList) {
      for (Species species in speciesList) {
        if (species.species_id == report.species_id) {
          this.species = species;
          break;
        }
      }
      if (species == null) {
        throw Exception("Failed to find species with ID: ${report.species_id}");
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
                      body: PlantInfoBox(species: species!, report: report)),
                  CardWithHeader(
                      header: "Reporting", body: WeedsReportingBox()),
                  //CardWithHeader(header: "RESOURCES", body: ResourcesBox())
                ]);
              } else {
                return Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
              }
            })
    );
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
            top: externalPadding,
            left: externalPadding,
            right: externalPadding),
        child: Container(
          // expand cards to fill screen width
          width: double.infinity,
          child: Card(
                elevation: 3,
                color: Color.fromRGBO(240, 240, 240, 1),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                // card contents
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      // space around the header text
                      padding: EdgeInsets.all(internalPadding),
                      child: Text(header,
                          style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: internalPadding, right: internalPadding, bottom: internalPadding),
                        child: body
                    )
                  ],
                )
            )
          ),
        );
  }
}

class PlantInfoBox extends StatelessWidget {
  final Species species;
  final Report report;
  final TextStyle headingStyle = GoogleFonts.openSans(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.black
  );
  final TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 11,
      color: Colors.black
  );

  PlantInfoBox({required this.species, required this.report}) : super();

  @override
  Widget build(BuildContext context) {
    print(species.council_declaration);
    return Row(
      children: [
        // info
        Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingColonBody("Common Name: ", species.name),
                HeadingColonBody("Scientific Name: ", species.species),
                HeadingColonBody("Family: ", species.family),
                HeadingColonBody("Council Declaration: ", HtmlUnescape().convert(species.council_declaration)), // fixme: doesn't fix the garble. i tried ~james
                // this doesn't work for some reason
                //HeadingColonBody("State Declaration: ", species.state_declaration.first),
                // HeadingColonBody("Control Methods: ", species.control_methods[0]),
                HeadingColonBody("Environmental Impact: ", ""),
                SeverityBar(SeverityBar.MED) // hard-code this for now
              ]
            )
        ),
        Padding(padding: EdgeInsets.only(left: internalPadding)),
        // image
        Expanded(
            // make a square that fills 40% of the available width, and crop the image into that square
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: Image.asset(report.photoLocations.first.image_filename)
              )
            )
        )
      ],
    );
  }
}

class SeverityBar extends StatelessWidget {

  static const int LOW = 0;
  static const int MED = 1;
  static const int HIGH = 2;

  final int severity;
  final double height = 20;

  final TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 11,
      color: Colors.black
  );

  SeverityBar(this.severity);

  @override
  Widget build(BuildContext context) {
      return Container(
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all()
        ),
        child:
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  // filled portion of the bar
                  Expanded(
                    flex: severity == LOW ? 1 : severity == MED ? 5 : 9,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(height / 2),
                              bottomLeft: Radius.circular(height / 2)
                          ),
                          color: severity == LOW ? Colors.yellow : severity == MED ? Colors.orange : Colors.red
                      ),
                    )
                  ),
                  // empty portion of the bar
                  Expanded(
                      flex: severity == LOW ? 9 : severity == MED ? 5 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(height / 2),
                                bottomRight: Radius.circular(height / 2)),
                            color: Colors.white
                        ),
                      )
                  ),
                ],
              ),
              // low-med-high text
              Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("low", style: bodyStyle),
                    Text("med", style: bodyStyle),
                    Text("high", style: bodyStyle)
                  ],
                ),
              )
            ],
          )
    );
  }
}

class HeadingColonBody extends StatelessWidget {

  final String heading;
  final String body;

  HeadingColonBody(this.heading, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
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
      ),
    );
  }
}

class WeedsReportingBox extends StatelessWidget {

  //final WeedsAroundSlider weedsAroundSlider = WeedsAroundSlider();

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
        Text("You have reported the location of this invasive species to the authorities, please add any additional information as required.", style: bodyStyle),
        //weedsAroundSlider
        ReportUpdateForm()
      ],
    );
  }
}

class WeedsAroundSlider extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _WeedsAroundSliderState();
}

class _WeedsAroundSliderState extends State {

  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Slider(
        min: 0,
        max: 1,
        divisions: 4,
        value: value,
        onChanged: (double value) {
          setState(() {
            this.value = value;
          });
        },
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
                      decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.white
                      ),
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

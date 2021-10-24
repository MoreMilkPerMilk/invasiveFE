import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:latlong2/latlong.dart';

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
        appBar: AppBar(
          title: Text("Report", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          iconTheme: IconThemeData(
              color: Colors.black,
              opacity: 1,
              size: 40
          )
        ),
        body: FutureBuilder(
            future:
                speciesFuture, // only build once we have retrieved species data
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(children: [
                  CardWithHeader(
                      header: "Species Info",
                      body: PlantInfoBox(species: species!, report: report)
                  ),
                  MapCard(LatLng(-27.4975, 153.0137)),
                  PhotoCard(Image.network(getImageURL(report.photoLocations.first).toString()))
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

class PhotoCard extends StatelessWidget {
  
  final Image image;
  
  PhotoCard(this.image);
  
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
                clipBehavior: Clip.hardEdge,
                elevation: 3,
                color: Color.fromRGBO(240, 240, 240, 1),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                // card contents
                child: image
            )
        )
    );
  }
}

class MapCard extends StatelessWidget {

  final LatLng location;

  MapCard(this.location);

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
          clipBehavior: Clip.hardEdge,
          elevation: 3,
          color: Color.fromRGBO(240, 240, 240, 1),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          // card contents
          child:
            Container(
              height: 256,
              child: FlutterMap(
                  options: MapOptions(
                    center: location,
                    zoom: 13.0,
                    interactiveFlags: InteractiveFlag.none,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                      subdomains: <String>['a', 'b'],
                    ),
                    MarkerLayerOptions(markers: [
                      Marker(
                        height: 40,
                        width: 40,
                        point: location,
                        builder: (ctx) => Icon(
                          Icons.location_pin
                        ),
                      )
                    ])
                  ]
              )
            )
        )
      )
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
            color: Colors.grey[200],
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

  PlantInfoBox({required this.species, required this.report}) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadingColonBody("Common Name: ", species.name),
          HeadingColonBody("Scientific Name: ", species.species),
          HeadingColonBody("Family: ", species.family),
          HeadingColonBody("State Declaration: ", species.state_declaration),
          HeadingColonBody("Council Declaration: ", species.council_declaration),
          Row(
            children: [
              HeadingColonBody("Environmental Impact: ", ""),
              Expanded(child: SeverityBar(species.severity))
            ],
          )
        ]
    );
  }
}

class SeverityBar extends StatelessWidget {

  final SpeciesSeverity severity;
  final double height = 20;

  final TextStyle bodyStyle = GoogleFonts.openSans(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.black
  );

  final TextStyle bodyStyleWhite = GoogleFonts.openSans(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white
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
                      flex: severity == SpeciesSeverity.LOW ? 1
                          : severity == SpeciesSeverity.MED_LOW ? 3
                          : severity == SpeciesSeverity.MED ? 5
                          : severity == SpeciesSeverity.MED_HIGH ? 7
                          : 9,
                      child: Container(
                        decoration: severity == SpeciesSeverity.HIGH ? BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(height / 2),
                              bottomLeft: Radius.circular(height / 2)
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(-0.6, 1.6),
                            stops: [0.0, 0.5, 0.5, 1],
                            colors: [
                              Colors.red,
                              Colors.red,
                              Colors.black,
                              Colors.black,
                            ],
                            tileMode: TileMode.repeated,
                          ),
                        ) : BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(height / 2),
                                bottomLeft: Radius.circular(height / 2)
                            ),
                            color: severity == SpeciesSeverity.LOW ? Colors.green
                                : severity == SpeciesSeverity.MED_LOW ? Colors.yellow
                                : severity == SpeciesSeverity.MED ? Colors.orange
                                : Colors.red
                        ),
                      )
                  ),
                  // empty portion of the bar
                  Expanded(
                      flex: severity == SpeciesSeverity.LOW ? 9
                          : severity == SpeciesSeverity.MED_LOW ? 7
                          : severity == SpeciesSeverity.MED ? 5
                          : severity == SpeciesSeverity.MED_HIGH ? 3
                          : 1,
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
                    Text(""),
                    Text(speciesSeverityToString(severity), style: severity == SpeciesSeverity.HIGH || severity == SpeciesSeverity.MED_HIGH ? bodyStyleWhite : bodyStyle),
                    Text("")
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
                  fontSize: 12,
                  color: Colors.black
              ),
              children: [
                TextSpan(
                    text: heading,
                    style: GoogleFonts.openSans(
                        fontSize: 12,
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

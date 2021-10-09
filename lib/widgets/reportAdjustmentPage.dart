import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:carousel_slider/carousel_slider.dart';

final TextStyle headingStyle = GoogleFonts.openSans(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.black
);
TextStyle bodyStyle = GoogleFonts.openSans(
    fontSize: 13,
    color: Colors.black
);
final double internalPadding = 10;
final double externalPadding = 10;

// ignore: must_be_immutable
class ReportAdjustmentPage extends StatelessWidget {
  Report report;
  Species? species;
  late Future<List<Species>> speciesFuture;


  ReportAdjustmentPage({required this.report}) : super() {
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
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ReportUpdateForm(report)
                );
              } else {
                return Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
              }
            })
    );
  }
}

class ReportUpdateForm extends StatefulWidget {

  final Report report;

  ReportUpdateForm(this.report);

  @override
  createState() => _ReportUpdateFormState();
}

class _ReportUpdateFormState extends State<ReportUpdateForm> {
  bool wrongAutomatedInformation = false;
  bool contactedByWeedsOfficer = false;
  String additionalComments = "";
  List<String> additionalPhotos = ['assets/placeholder.png', 'assets/placeholder.png'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("You have reported the location of this invasive species to the authorities, please add any additional information as required.", style: bodyStyle),
        wrongInfoCheckbox(),
        authoritiesContactCheckbox(),
        Text("Additional comments:", style: bodyStyle),
        additionalCommentsField(),
        Text("Current photos:"),
        photosTakenSlider(),
        takeMorePhotosButton(),
        Spacer(),
        submitButton()
      ],
    );
  }

  Row wrongInfoCheckbox() {
    return Row(
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
    );
  }

  Row authoritiesContactCheckbox() {
    return Row(
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
    );
  }

  Container additionalCommentsField() {
    return Container(
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
        )
    );
  }

  CarouselSlider photosTakenSlider() {
    return CarouselSlider(
      options: CarouselOptions(
          height: 400.0,
          enableInfiniteScroll: false,
          viewportFraction: 0.85
      ),
      items: List.from((widget.report.photoLocations.map((i) => i.image_filename).toList())..addAll(additionalPhotos)).map((i) => Image.asset(i)).toList(),
    );
  }

  Align takeMorePhotosButton() {
    return Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {},
          child: Text("Add More Photos"),
        )
    );
  }

  Align submitButton() {
    return Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {},
          child: Text("Submit"),
        )
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
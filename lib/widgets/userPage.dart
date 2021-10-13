import 'package:flutter/material.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/Species.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:invasive_fe/widgets/reportPage.dart';
import 'package:line_icons/line_icon.dart';

Map<int, Species> species = {};

// todo change to reports by user.
class UserPage extends StatefulWidget {
  UserPage();

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Report> reports = [];
  late Future loaded;

  @override
  void initState() {
    super.initState();
    Future reportsFuture = getAllReports();
    Future speciesFuture = getAllSpecies();
    reportsFuture.then((value) => reports = value);
    loaded = Future.wait([reportsFuture, speciesFuture]);

    // create the {species id => species} map
    speciesFuture.then((speciesList) => species = Map.fromIterable(
        speciesList, // convert species list to map for quick id lookup
        key: (e) => e.species_id,
        value: (e) => e)
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      "http://cdn.onlinewebfonts.com/svg/img_299586.png",
                      width: 75,
                    ),
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Hamish Bultitude',
                        style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '4/10/2021',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Spacer()
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Achievements',
              style: TextStyle(fontSize: 23, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Achievement("Find 10 Low Severity", "7/10/2021", "lowsev_1"),
                  Achievement("Find 20 Low Severity", "20/10/2021", "lowsev_2"),
                  Achievement("Find 10 Medium Severity", "10/10/2021", "medsev_1"),
                  Achievement("Find 10 Medium Severity", "7/10", "none"),
                  Achievement("Find Plants in 5 Unique Councils", "1/11/2021", "location_1"),
                  Achievement("Find Plants in 10 Unique Councils", "6/10", "none"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Reports',
              style: TextStyle(fontSize: 23, color: Colors.black),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 1,
            child: FutureBuilder(
                future: loaded,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                        child: new ListView.builder(
                            itemCount: reports.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return ReportCard(reports[index]);
                            }));
                  } else {
                    return Align(alignment: Alignment.center, child: CircularProgressIndicator());
                  }
                }),
          )
        ],
      ),
    );
  }
}

class ReportCard extends StatefulWidget {
  Report report;

  ReportCard(this.report);

  @override
  _ReportCardState createState() => new _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportPage(report: widget.report)),
        );
      },
      child: new Container(
          height: 150,
          child: Card(
            elevation: 5,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/weeds/lantana.jpg",
                    height: 75,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Text(species[widget.report.species_id]!.name),
                        Text(widget.report.name),
                        Text(widget.report.status),
                        // Text(report.id.toString()),
                        // Text(report.notes),
                        // Text(report.photoLocations.toString()),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 50,
                        maxWidth: 100
                      ),
                      child: ClipRRect(child: renderImage(), borderRadius: BorderRadius.all(Radius.circular(10.0)))
                  ),
                ),
                Icon(
                    Icons.arrow_forward_ios_rounded
                ),
              ],
            ),
          )),
    );
  }

  Widget renderImage() {
    if (widget.report.photoLocations.isNotEmpty) {
      return Image.network(getImageURL(widget.report.photoLocations.first).toString());
    } else {
      return Image.asset("assets/badges/none.jpg");
    }
  }
}

class Achievement extends StatelessWidget {
  Achievement(this.title, this.date, this.badge_name);

  String title;
  String date;
  String badge_name;

  // const Achievement({
  //   Key? key,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        // color: Colors.purple[600],
        child: Card(
          elevation: 5,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                child: Image.asset(
                  "assets/badges/$badge_name.jpg",
                  width: 65,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (date != "")
                      Text(
                        "$date",
                        textAlign: TextAlign.center,
                      )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

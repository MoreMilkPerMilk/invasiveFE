import 'package:flutter/material.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/services/httpService.dart';
import 'package:line_icons/line_icon.dart';

// todo change to reports by user.
class UserPage extends StatefulWidget {
  UserPage();

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late List<Report> reports;
  late Future loaded;

  @override
  void initState() {
    super.initState();
    Future reports = getAllReports();
    reports.then((value) => print(value));
    loaded = Future.wait([reports]);
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
              elevation: 15,
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
          Container(
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
          Expanded(
            flex: 1,
            child: FutureBuilder(
                future: loaded,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      child: ListView(
                        children: <Widget>[
                          Container(
                            height: 50,
                            color: Colors.amber[600],
                            child: const Center(child: Text('Entry A')),
                          ),
                          Container(
                            height: 50,
                            color: Colors.amber[500],
                            child: const Center(child: Text('Entry B')),
                          ),
                          Container(
                            height: 1000,
                            color: Colors.amber[100],
                            child: const Center(child: Text('Entry C')),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()
                    );
                  }
                }),
          )
        ],
      ),
    );
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

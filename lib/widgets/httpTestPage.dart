import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/Report.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/widgets/reportAdjustmentPage.dart';
import 'package:objectid/objectid.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import '../services/httpService.dart';

// broken due to modified WeedInstance json structure

class HttpTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Locations");
                getAllPhotoLocations();
              },
              child: Text('/Locations'),
            ),
            Spacer(),
            ElevatedButton(
              child: Text("Report Adjustment Page"),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportAdjustmentPage(
                    report: Report(
                        id: ObjectId(),
                        status: "status",
                        notes: "notes",
                        polygon: GeoJsonMultiPolygon(),
                        photoLocations: [
                          PhotoLocation(
                              id: ObjectId(),
                              photo: new File("assets/placeholder.png"),
                              location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: -27.4975, longitude: 153.0137)),
                              image_filename: 'placeholder.png'
                          )
                        ],
                        name: "test",
                        species_id: 41
                    ),
                  ))
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                log("/Add PhotoLocation");
                ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
                print(imgBytes);
                Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
                XFile xFile = XFile.fromData(imgUint8List, path: 'assets/placeholder.png'); // fixme: this has no path set...
                xFile.saveTo("/storage/emulated/0/Download/image.png");
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: new File("/storage/emulated/0/Download/image.png"),
                    location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: 4, longitude: 4)),
                    image_filename: 'placeholder.png' //BAD
                );
                addPhotoLocation(loc);
              },
              child: Text('/Add PhotoLocation'),
            ),
            ElevatedButton(
              onPressed: () async {
                log("/Delete Location");
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: new File(""),
                    location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: 4, longitude: 4)),
                    image_filename: 'placeholder.png' //BAD
                );
                deleteLocation(loc);
              },
              child: Text('/Delete Location'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                log("/Add Report");
                // create photolocation for report
                ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
                print(imgBytes);
                Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
                XFile xFile = XFile.fromData(imgUint8List, path: 'assets/placeholder.png');
                xFile.saveTo("/storage/emulated/0/Download/image.png");
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: new File("/storage/emulated/0/Download/image.png"),
                    location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: 4, longitude: 4)),
                    image_filename: 'placeholder.png' //BAD
                );

                // create report
                var report = new Report(
                    id: ObjectId(),
                    species_id: 1,
                    name: 'test report',
                    status: 'closed',
                    photoLocations: [],  // currently backend requires that we add photolocation after creating report
                    notes: '',
                    polygon: new GeoJsonMultiPolygon()
                );
                addReport(report);
                loc = await addPhotoLocation(loc);
                getAllReports();
              },
              child: Text('/Add Report'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Users");
                // getAllUsers();
                // getUserById(1);
              },
              child: Text('/Users'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Add User");
                var user = User(id: ObjectId(), first_name: "test user", last_name: "last", date_joined: "1999-01-01", reports: []);
                addUser(user);
              },
              child: Text('/Add User'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Delete User");
                deleteUser(999);
              },
              child: Text('/Delete User'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Species");
                getAllSpecies();
                getSpeciesById(48);
              },
              child: Text('/Species'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("add photoplocation");
                addPhotoLocation(new PhotoLocation(id: new ObjectId(), photo: new File(''), image_filename: 'assets/placeholder.png', location: new GeoJsonPoint(geoPoint: new GeoPoint(latitude: 1, longitude: 1))));
                // getUserById(1);
              },
              child: Text('add photolocation'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/councils/peek");
                getAllCouncils();
                // getUserById(1);
              },
              child: Text('/councils/peek'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/councils/613ef4c84ed77d2294042db6");
                getCouncilById(ObjectId.fromHexString("613ef4c84ed77d2294042db6"));
                // getUserById(1);
              },
              child: Text('/councils/bundaberg'),
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: 'Search for a council by name',
                  labelText: 'Council search'
              ),
              onSubmitted: (String? value) {
                print("field has value " + value.toString());
                log("SAVEDDDD");
                String search_term = "";
                if (value != null) {
                  search_term = value;
                }
                log("SAVED");
                searchForCouncilBySearchTerm(search_term);
              },
            ),
            ElevatedButton(
              onPressed: () {
                log("/councils/search/location");
                searchForCouncilByLocation(new PhotoLocation(id: ObjectId(), photo: File(""), image_filename: "", location: GeoJsonPoint(geoPoint: new GeoPoint(latitude: 27.4975, longitude: 153.0137))));
              },
              child: Text('/councils/search/location (using uni lat long)'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/communities/peek");
                peekCommmunities();
                // getUserById(1);
              },
              child: Text('/communities/peek'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/communities/weedwackers");
                getCommunity(ObjectId.fromHexString("612ef1285412b4a4e946adff"));
                // getUserById(1);
              },
              child: Text('/communities/weedwackers'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/communities/locations/weedwackers");
                getCommunityLocations(ObjectId.fromHexString("612ef1285412b4a4e946adff"));
                // getUserById(1);
              },
              child: Text('/communities/locations/weedwackers'),
            ),

          ],
        ),
      ),
    );
  }
}

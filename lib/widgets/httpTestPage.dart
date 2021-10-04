import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:invasive_fe/widgets/reportPage.dart';
import 'package:objectid/objectid.dart';
import 'package:uuid/uuid.dart';
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
            ElevatedButton(
              onPressed: () {
                var weed = WeedInstance(
                    species_id: 41,
                    discovery_date: "2000/03/02",
                    speciesName: "weedy weed",
                    info: "some info",
                    image_filename: "image_url");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage(weed: weed)
                ));
              },
              child: Text('Report Page'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Locations");
                getAllPhotoLocations();
              },
              child: Text('/Locations'),
            ),
            ElevatedButton(
              onPressed: () async {
                log("/Add Location w/o Weeds");
                ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
                print(imgBytes);
                Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
                XFile xFile = XFile.fromData(imgUint8List, path: 'assets/placeholder.png'); // fixme: this has no path set...
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: xFile,
                    location: GeoPoint(latitude: 4, longitude: 4),
                    weeds_present: []
                );
                addPhotoLocation(loc);
              },
              child: Text('/Add Location w/o Weeds'),
            ),
            ElevatedButton(
              onPressed: () async {
                log("/Add PhotoLocation");
                ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
                Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
                XFile xFile = XFile.fromData(imgUint8List);
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: xFile,
                    location: GeoPoint(latitude: 4, longitude: 4),
                    weeds_present: []
                );
                addPhotoLocation(loc);
              },
              child: Text('/Add Location w/ Weeds'),
            ),
            ElevatedButton(
              onPressed: () async {
                log("/Delete Location");
                ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
                Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
                XFile xFile = XFile.fromData(imgUint8List);
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: xFile,
                    location: GeoPoint(latitude: 4, longitude: 4),
                    weeds_present: []
                );
                deleteLocation(loc);
              },
              child: Text('/Delete Location'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Users");
                getAllUsers();
                // getUserById(1);
              },
              child: Text('/Users'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Add User");
                var user = User(person_id: 999, first_name: "test user", last_name: "last", date_joined: "1999-01-01", count_identified: 0, previous_tags: []);
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
          ],
        ),
      ),
    );
  }
}
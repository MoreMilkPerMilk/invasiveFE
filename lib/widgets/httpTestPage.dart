import 'dart:developer';
import 'dart:io';
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
import 'package:file_picker/file_picker.dart';

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
                    removed: false,
                    replaced: false,
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
                File file = new File("");
                log("/Add PhotoLocation");
                String path = 'assets/placeholder.png';
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
                String path = 'assets/placeholder.png';
                ByteData imgBytes = await rootBundle.load('assets/placeholder.png');
                Uint8List imgUint8List = imgBytes.buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
                XFile xFile = XFile.fromData(imgUint8List);
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
                addPhotoLocation(new PhotoLocation(id: new ObjectId(), photo: new File(''), image_filename: 'file.txt', location: new GeoJsonPoint(geoPoint: new GeoPoint(latitude: 1, longitude: 1))));
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

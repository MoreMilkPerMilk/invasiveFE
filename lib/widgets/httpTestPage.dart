import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:invasive_fe/models/PhotoLocation.dart';
import 'package:invasive_fe/models/User.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
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

                FilePickerResult? result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  String? path = result.files.single.path;

                  String p = "";
                  if (path != null) {
                    p = path;
                  }
                  file = File(p);
                } else {
                  // User canceled the picker
                }
                // XFile xFile = XFile.fromData(imgUint8List, path: 'assets/placeholder.png'); // fixme: this has no path set...
                var loc = PhotoLocation(
                    id: ObjectId(),
                    photo: file,
                    location: GeoPoint(latitude: 4, longitude: 4),
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
                    location: GeoPoint(latitude: 4, longitude: 4),
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
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Councils");
                getAllUsers();
                // getUserById(1);
              },
              child: Text('/Councils'),
            ),
          ],
        ),
      ),
    );
  }
}

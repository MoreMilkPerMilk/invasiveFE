import 'dart:developer';
import 'dart:html';
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
              onPressed: () {
                log("/Add Location w/o Weeds");
                var loc = PhotoLocation(
                    id: ObjectId(),
                    name: "152 Gailey Road Brisbane",
                    photo: ,
                    location: GeoPoint(latitude: 4, longitude: 4),
                    weeds_present: []
                );
                addLocation(loc);
              },
              child: Text('/Add Location w/o Weeds'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Add Location w/ Weeds");
                var weed = WeedInstance(species_id: 0, discovery_date: "2000/03/02", removed: false, replaced: false, image_filename: "image_url");
                var loc = PhotoLocation(
                    id: ObjectId(),
                    name: "152 Gailey Road Brisbane",
                    location:,
                    weeds_present: [weed]
                );
                addLocation(loc);
              },
              child: Text('/Add Location w/ Weeds'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Delete Location");
                var loc = PhotoLocation(
                    id: ObjectId(),
                    name: "152 Gailey Road Brisbane",
                    lat:0.0, long:0.0,
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
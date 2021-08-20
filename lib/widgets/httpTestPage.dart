import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:invasive_fe/models/Location.dart';
import 'package:invasive_fe/models/WeedInstance.dart';
import 'package:uuid/uuid.dart';

import '../services/httpService.dart';

class HttpTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HTTP Test Page"),
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () {
                log("/Locations");
                getAllLocations();
              },
              child: Text('/Locations'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Add Location w/o Weeds");
                var loc = Location(name: "152 Gailey Road Brisbane", lat:0.0, long:0.0, weeds_present: []);
                addLocation(loc);
              },
              child: Text('/Add Location w/o Weeds'),
            ),
            ElevatedButton(
              onPressed: () {
                log("/Add Location w/ Weeds");
                var weed = WeedInstance(uuid: Uuid().v4(), image_url: "image_url", species_id: 1, discovery_date: "2000/03/02", removed: false, replaced: false);
                var loc = Location(name: "152 Gailey Road Brisbane", lat:0.0, long:0.0, weeds_present: [weed]);
                addLocation(loc);
              },
              child: Text('/Add Location w/ Weeds'),
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
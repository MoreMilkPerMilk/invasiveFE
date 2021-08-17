import 'dart:developer';
import 'package:flutter/material.dart';

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
            ElevatedButton(
              onPressed: () {
                log("/Locations");
                getAllLocations();
              },
              child: Text('/Locations'),
            ),
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
                log("/Species");
                getAllSpecies();
                getSpeciesById(48);
              },
              child: Text('/Species'),
            ),
          ],
        ),
      ),
    );
  }
}
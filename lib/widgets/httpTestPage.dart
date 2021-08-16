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
        child: ElevatedButton(
          onPressed: () {
            log("/Locations");
            getAllLocations();
          },
          child: Text('/Locations'),
        ),
      ),
    );
  }
}
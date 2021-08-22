import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

import 'package:invasive_fe/models.dart';

var API_URL = 'http://127.0.0.1:8000';

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
            log("Hello!");
            getAllLocations();
          },
          child: Text('Test /person!'),
        ),
      ),
    );
  }
}


/// communicate with backend server to HTTP GET all weed instances.
Future<List<User>> getAllLocations() async {
  final response = await http.get(Uri.parse(API_URL + "/users"));

  if (response.statusCode == 200) {
    log(response.body);
    // var result = await compute(User.parseUserList, response.body);
    var result = User.parseUserList(response.body);
    result.forEach((element) {
      print(element);
    });

    // return result;
    return [];
    // return compute(WeedInstance.parseWeedInstanceList, response.body);
  } else {
    return [];
  }
}
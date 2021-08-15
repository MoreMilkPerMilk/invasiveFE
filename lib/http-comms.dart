import 'package:flutter/material.dart';
import 'dart:developer';

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
          },
          child: Text('Test hello!'),
        ),
      ),
    );
  }
}
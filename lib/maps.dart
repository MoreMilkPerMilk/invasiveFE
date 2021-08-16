import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var title = Text("Maps Page");
    var appBar = AppBar(title: title);
    var body = Center();
    var scaffold = Scaffold(appBar: appBar, body: body);
    return scaffold;
  }
}


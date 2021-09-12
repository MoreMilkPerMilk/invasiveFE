import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
          children: [
            CardWithHeader(header: "header", body: Text("body"))
          ]
      )
    );
  }
}

class CardWithHeader extends Card {

  final String header;
  final Widget body;

  CardWithHeader({required this.header, required this.body}) : super(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // sexy curves
    ),
    child:
      Column(
        children: [
          Text(header),
          body
        ],
      )
  );
}
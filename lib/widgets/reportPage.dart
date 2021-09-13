import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
          children: [
            CardWithHeader(header: "PLANT INFO", body: Text("body")),
            CardWithHeader(header: "WEEDS REPORTING", body: Text("body")),
            CardWithHeader(header: "RESOURCES", body: Text("body"))
          ]
      )
    );
  }
}

class CardWithHeader extends StatelessWidget {

  final String header;
  final Widget body;
  final double externalPadding = 16;
  final double internalPadding = 10;
  final double borderWidth = 2;

  CardWithHeader({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
        return Padding(
          // space around the card
          padding: EdgeInsets.only(
              top: externalPadding,
              left: externalPadding,
              right: externalPadding),
          child: Container(
            // expand cards to fill screen width
            width: double.infinity,
            child: Card(
                shape: Border.all(width: borderWidth),
                // card contents
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        // space around the header text
                        padding: EdgeInsets.all(internalPadding),
                        child: Text(header,
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                        ),
                      )
                    ),
                    Divider(
                      thickness: borderWidth,
                      height: 0,
                      color: Colors.black,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.all(internalPadding),
                        child: body
                      )
                    )
                  ],
                )
            ),
          )
        );
  }
}
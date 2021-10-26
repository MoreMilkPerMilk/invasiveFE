import 'package:flutter/material.dart';
import 'package:invasive_fe/models/Community.dart';
import 'package:invasive_fe/models/Council.dart';
import 'package:invasive_fe/models/Landcare.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPanel extends StatefulWidget {
  final PanelController _pc;
  final Council? council;
  final Community? community;
  final Landcare? landcare;

  MapPanel(this._pc, this.council, this.community, this.landcare);

  @override
  _PanelState createState() {
    return new _PanelState();
  }
}

class _PanelState extends State<MapPanel> {
  bool _reportButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    String title = "";
    String description = "";
    if (widget.council != null) {
      title = widget.council!.name + " Council";
      description = "The region clicked on belongs to ${widget.council!.name} Council.";
    } else if (widget.community != null) {
      title = widget.community!.name;
      description =
          "A community containing ${widget.community!.suburbs.length} suburbs and ${widget.community!.councils.length} council areas.";
      description +=
          "There are ${widget.community!.members.length} members in this community.";
      // description += "Suburbs:";
      // int i = 0;
      // widget.community!.suburbs.forEach((String suburb) {
      //   if (i < widget.community!.suburbs.length - 1) {
      //     description += suburb + ", ";
      //   } else {
      //     description += suburb + ".";
      //   }
      //   i++;
      // });
      // i = 0;
      // widget.community!.councils.forEach((String council) {
      //   if (i < widget.community!.councils.length - 1) {
      //     description += council + ", ";
      //   } else {
      //     description += council + ".";
      //   }
      //   i++;
      // });
    } else if (widget.landcare != null) {
      title = widget.landcare!.nlp_mu;
      description =
          widget.landcare!.area_desc + " within " + widget.landcare!.state;
    }

    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.,
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text.rich(
                      TextSpan(
                        text: title,
                        style: TextStyle(fontSize: 23),
                      ),
                    )),
                Text.rich(TextSpan(
                  text: description,
                  style: TextStyle(fontSize: 15),
                ))
              ],
            )));
  }
}

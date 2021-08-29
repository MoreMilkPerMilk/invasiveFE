import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Panel extends StatelessWidget {
  Panel(this.foundSpecies, this._pc);

  final String foundSpecies;
  final PanelController _pc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text.rich(
              TextSpan(
                text: 'You Found:', // default text style
                children: <TextSpan>[
                  // TextSpan(
                  //     text: ' beautiful ',
                  //     style: TextStyle(fontStyle: FontStyle.italic)),
                  TextSpan(
                      text: '$foundSpecies',
                      style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          // ElevatedButton(
          //     onPressed: () {
          //       _pc.close();
          //     },
          //     child: Text("Close Window")
          // )
        ],
      ),
    );
  }
}

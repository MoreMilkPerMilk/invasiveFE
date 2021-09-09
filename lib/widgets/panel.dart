import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Panel extends StatelessWidget {
  Panel(this.foundSpecies, this._pc);

  String foundSpecies;

  PanelController _pc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                text: 'You Found: ',
                style: TextStyle(fontSize: 30),
                children: <TextSpan>[
                  TextSpan(text: '$foundSpecies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(
                  image: NetworkImage('https://weeds.brisbane.qld.gov.au/sites/default/files/styles/large/public/images/lantana_camara17.jpg?itok=6FcRI2y7'),
                  width: 300,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("More Info"),
                  onPressed: () => {},
                ),
                ElevatedButton(
                  child: Text("Report To Council"),
                  onPressed: () => {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

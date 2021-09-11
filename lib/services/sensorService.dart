import 'dart:collection';
import 'dart:math';

import 'package:tuple/tuple.dart';

// velocity threshold constants
const int MAX_LOOK_BACK_TIME_MS = 2000;

class StabilityVariables {
  final List<double> accelerometerValues;
  final ListQueue<Tuple2<int, double>> velocityBuffer;

  StabilityVariables(this.accelerometerValues, this.velocityBuffer);
}

bool stabilityDetection(StabilityVariables params) {
  List<double> accelerometerValues = params.accelerometerValues;
  ListQueue<Tuple2<int, double>> velocityBuffer = params.velocityBuffer;

  int currentTime = new DateTime.now().millisecondsSinceEpoch;
  // calculate the maximum absolute acceleration
  double x = accelerometerValues[0];
  double y = accelerometerValues[1];
  double z = accelerometerValues[2];
  double speed = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
  print(speed);
  if (speed > 1) {
    print("TOO FAST");
    return true;
  } else {
    return false;
  }
    // print(speed);
  // velocityBuffer.addLast(new Tuple2(currentTime, speed));
  // determine if enough time has elapsed
  // if (velocityBuffer.last.item1 - velocityBuffer.first.item1 > MAX_LOOK_BACK_TIME_MS) {
  //   double sumSpeed = velocityBuffer.fold(0, (t, e) => t + e.item2);
  //   double avgSpeed = sumSpeed / velocityBuffer.length;
  //   print(avgSpeed);
    // if (avgSpeed > 0.5) {
    //   print("TOO FAST");
    //   print(avgSpeed);
    // }
    // velocityBuffer.removeFirst();
  // }
}

void poggers(String str) {
  print(str);
}
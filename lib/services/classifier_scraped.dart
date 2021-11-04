
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier.dart';

class ScrapedWeedClassifier extends Classifier {
  ScrapedWeedClassifier({int? numThreads}) : super(numThreads: numThreads);

  @override
  String get modelName => 'model.tflite';

  @override
  String get labelsFileName => "assets/tflitelabels.txt";

  @override
  int get labelsLength => 356;

  var mean = [103.939, 116.779, 123.68];
  var std = [58.393, 57.12, 57.375];

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp.multipleChannels(mean, std);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);
}
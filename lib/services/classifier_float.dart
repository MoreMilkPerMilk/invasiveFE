
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier.dart';

class ClassifierFloat extends Classifier {
  ClassifierFloat({int? numThreads}) : super(numThreads: numThreads);

  @override
  String get modelName => 'resnet.tflite';

  @override
  String get labelsFileName => 'assets/labels.txt';

  @override
  int get labelsLength => 9;

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);
}
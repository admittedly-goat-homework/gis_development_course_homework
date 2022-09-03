import 'package:flutter/cupertino.dart';

class SingleImageModel {
  int? id;
  String? timeStamp;
  double? x1;
  double? y1;
  double? x2;
  double? y2;
  double? x3;
  double? y3;
  double? x4;
  double? y4;

  SingleImageModel(
      {required this.id,
      required this.timeStamp,
      required this.x1,
      required this.y1,
      required this.x2,
      required this.y2,
      required this.x3,
      required this.y3,
      required this.x4,
      required this.y4});

  String? MyToString() {
    return this.timeStamp;
  }
}

class CoregistrationMapModel extends ChangeNotifier {
  double? x1;
  double? y1;
  double? x2;
  double? y2;
  double? x3;
  double? y3;
  double? x4;
  double? y4;
  bool isInit = false;
  void updateExtent() {
    notifyListeners();
  }
}

class CoregistrationCommitData extends ChangeNotifier {
  String master = '';
  String slave = '';
  String masterSwath = '';
  String slaveSwath = '';
  bool get isInit {
    return (master != '') &
        (slave != '') &
        (masterSwath != '') &
        (slaveSwath != '');
  }
}

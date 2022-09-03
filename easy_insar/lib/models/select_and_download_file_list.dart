import 'dart:collection';
import 'dart:convert';
import 'package:easy_insar/properties/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SingleImageRectanglePosition {
  SingleImageRectanglePosition(
      {required this.x1,
      required this.y1,
      required this.x2,
      required this.y2,
      required this.x3,
      required this.y3,
      required this.x4,
      required this.y4});
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double x3;
  final double y3;
  final double x4;
  final double y4;
}

class SingleSatelliteDownloadEntry {
  SingleSatelliteDownloadEntry({
    required int this.id,
    required String this.timeString,
    required String this.size,
    required bool this.isSelected,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double x3,
    required double y3,
    required double x4,
    required double y4,
  }) {
    this.position = SingleImageRectanglePosition(
        x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, x4: x4, y4: y4);
  }

  final int id;
  final String timeString;
  final String size;
  bool isSelected;
  late final SingleImageRectanglePosition position;
}

class SatelliteDownloadInfoModel extends ChangeNotifier {
  List<SingleSatelliteDownloadEntry> _entries = [];
  int viewingId = -1;
  void addEntry(
      int id,
      String timeString,
      String size,
      bool isSelected,
      double x1,
      double y1,
      double x2,
      double y2,
      double x3,
      double y3,
      double x4,
      double y4) {
    _entries.add(SingleSatelliteDownloadEntry(
        id: id,
        timeString: timeString,
        size: size,
        isSelected: isSelected,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        x3: x3,
        y3: y3,
        x4: x4,
        y4: y4));
    notifyListeners();
  }

  void clearEntry() {
    _entries.clear();
    viewingId = -1;
    notifyListeners();
  }

  void switchSelected(int id) {
    for (SingleSatelliteDownloadEntry entry in _entries) {
      if (entry.id == id) {
        entry.isSelected = !entry.isSelected;
      }
    }
    notifyListeners();
  }

  List<int> getAllSelectedId() {
    List<int> selectedIds = [];
    for (SingleSatelliteDownloadEntry entry in _entries) {
      if (entry.isSelected) {
        selectedIds.add(entry.id);
      }
    }
    return selectedIds;
  }

  void changeViewingId(int id) {
    viewingId = id;
    notifyListeners();
  }

  UnmodifiableListView<SingleSatelliteDownloadEntry> getAllEntries() {
    return UnmodifiableListView<SingleSatelliteDownloadEntry>(_entries);
  }
}

class SatelliteDownloadSelectBoxModel extends ChangeNotifier {
  double lowX = double.maxFinite;
  double lowY = double.maxFinite;
  double maxX = -double.maxFinite;
  double maxY = -double.maxFinite;
  bool isFinishedDrawingPolygon = false;
  bool firstPointSelected = false;
  void resetPosition() {
    lowX = double.maxFinite;
    lowY = double.maxFinite;
    maxX = -double.maxFinite;
    maxY = -double.maxFinite;
  }
}

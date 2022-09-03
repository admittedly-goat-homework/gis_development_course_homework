import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainLeftSelectionAreaVisibility extends ChangeNotifier {
  bool _isVisible = true;
  bool get isVisible => _isVisible;
  void changeVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}

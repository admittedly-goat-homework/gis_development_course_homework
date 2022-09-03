import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PanelSelectionModel extends ChangeNotifier {
  int _selectedPanel = 0;

  int getSelectedPanel() => _selectedPanel;

  void setSelectedPanel(int panel) {
    _selectedPanel = panel;
    notifyListeners();
  }
}

import 'package:easy_insar/models/panel_selection.dart';
import 'package:easy_insar/properties/panel_widget_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_insar/widgets/main_scaffold_widgets.dart';
import 'package:easy_insar/models/main_left_selection_area_visibility.dart';
import 'package:easy_insar/properties/panel_name.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'HarmonyOSSans'),
      title: 'Easy InSAR',
      home: ChangeNotifierProvider(
          create: (context) => PanelSelectionModel(),
          child: Consumer<PanelSelectionModel>(
            builder: ((context, value, child) =>
                HomePage(panelId: value.getSelectedPanel())),
          )),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({required this.panelId, Key? key}) : super(key: key);

  final int panelId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainLeftSelectionAreaVisibility(),
      child: Row(
        children: [
          Consumer<MainLeftSelectionAreaVisibility>(
              builder: (context, value, child) {
            // left part of the application
            return SizedBox(
              width: value.isVisible ? 360 : 1,
              child: Container(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 241, 244, 250)),
                child: Scaffold(
                  backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                  appBar: AppBar(
                    title: Text(
                      'Easy InSAR',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    elevation: 0,
                    backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                    foregroundColor: Color.fromARGB(255, 67, 71, 78),
                  ),
                  body: ListView(
                    controller: ScrollController(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    children: [
                      LeftPanelSelectButton(
                        tipText: 'Guidance and Help',
                        isSelected: false,
                        isTipOrGroupName: true,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 0,
                        currentSelectedPanelId: panelId,
                        icon: Icon(Icons.home_rounded),
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 1,
                        currentSelectedPanelId: panelId,
                        icon: Icon(Icons.satellite_alt),
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 2,
                        currentSelectedPanelId: panelId,
                        icon: Icon(Icons.play_arrow_rounded),
                      ),
                      const Divider(
                        height: 10,
                        thickness: 0,
                        indent: 16,
                        endIndent: 16,
                        color: Color.fromARGB(255, 115, 119, 127),
                      ),
                      LeftPanelSelectButton(
                        tipText: 'Processing',
                        isSelected: false,
                        isTipOrGroupName: true,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 3,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 4,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 5,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 6,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 7,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 8,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 9,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 10,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 11,
                        currentSelectedPanelId: panelId,
                      ),
                      LeftPanelSelectButtonByPanelIdAndIcon(
                        panelId: 12,
                        currentSelectedPanelId: panelId,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // right part of the application
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 224, 233, 244),
            ),
            child: Scaffold(
              backgroundColor: Color.fromRGBO(0, 0, 0, 0),
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                foregroundColor: Color.fromARGB(255, 27, 27, 27),
                elevation: 0,
                title: Row(
                  children: [
                    RightPanelAppBarMenuVisibilityChanger(
                      currentSelectedPanelId: panelId,
                    ),
                    SizedBox(
                      width: 96,
                    ),
                    Expanded(
                        child: Center(
                            child: Text(
                      PanelName.names[panelId]!,
                      style: TextStyle(fontSize: 22),
                    ))),
                    RightPanelAppBarDownload(
                      currentSelectedPanelId: panelId,
                    ),
                    RightPanelAppBarWorkspace(
                      currentSelectedPanelId: panelId,
                    ),
                    RightPanelAppBarInfo(
                      currentSelectedPanelId: panelId,
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 241, 244, 250),
                      borderRadius: BorderRadius.circular(16)),
                  child:
                      Container(child: PanelWidgets.panelWidgetList[panelId]),
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}

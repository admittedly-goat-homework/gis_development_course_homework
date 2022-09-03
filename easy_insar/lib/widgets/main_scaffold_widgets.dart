import 'package:easy_insar/models/main_left_selection_area_visibility.dart';
import 'package:easy_insar/models/panel_selection.dart';
import 'package:easy_insar/properties/panel_name.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RightPanelAppBarButton extends StatelessWidget {
  const RightPanelAppBarButton({
    required this.onTap,
    required this.myIcon,
    this.selected = false,
    Key? key,
  }) : super(key: key);
  final void Function()? onTap;
  final Widget myIcon;
  final selected;
  @override
  Widget build(BuildContext context) {
    return selected
        ? Ink(
            decoration: ShapeDecoration(
              color: Color.fromARGB(255, 159, 201, 255),
              shape: CircleBorder(),
            ),
            child: IconButton(
              onPressed: onTap,
              icon: myIcon,
              splashRadius: 20,
            ))
        : IconButton(
            onPressed: onTap,
            icon: myIcon,
            splashRadius: 20,
          );
  }
}

class RightPanelAppBarMenuVisibilityChanger extends StatelessWidget {
  const RightPanelAppBarMenuVisibilityChanger({
    required this.currentSelectedPanelId,
    Key? key,
  }) : super(key: key);

  final currentSelectedPanelId;

  @override
  Widget build(BuildContext context) {
    return RightPanelAppBarButton(
      onTap: () {
        Provider.of<MainLeftSelectionAreaVisibility>(context, listen: false)
            .changeVisibility();
      },
      myIcon: Icon(Icons.menu),
    );
  }
}

class RightPanelAppBarInfo extends StatelessWidget {
  const RightPanelAppBarInfo({
    required this.currentSelectedPanelId,
    Key? key,
  }) : super(key: key);

  final currentSelectedPanelId;

  @override
  Widget build(BuildContext context) {
    return RightPanelAppBarButton(
      onTap: () => Provider.of<PanelSelectionModel>(context, listen: false)
          .setSelectedPanel(16),
      myIcon: Icon(Icons.info_rounded),
      selected: currentSelectedPanelId == 16,
    );
  }
}

class RightPanelAppBarWorkspace extends StatelessWidget {
  const RightPanelAppBarWorkspace({
    required this.currentSelectedPanelId,
    Key? key,
  }) : super(key: key);

  final currentSelectedPanelId;

  @override
  Widget build(BuildContext context) {
    return RightPanelAppBarButton(
      onTap: () => Provider.of<PanelSelectionModel>(context, listen: false)
          .setSelectedPanel(15),
      myIcon: Icon(Icons.folder_outlined),
      selected: currentSelectedPanelId == 15,
    );
  }
}

class RightPanelAppBarDownload extends StatelessWidget {
  const RightPanelAppBarDownload({
    required this.currentSelectedPanelId,
    Key? key,
  }) : super(key: key);

  final currentSelectedPanelId;

  @override
  Widget build(BuildContext context) {
    return RightPanelAppBarButton(
      onTap: () => Provider.of<PanelSelectionModel>(context, listen: false)
          .setSelectedPanel(14),
      myIcon: Icon(Icons.file_download_outlined),
      selected: currentSelectedPanelId == 14,
    );
  }
}

class LeftPanelSelectButton extends StatelessWidget {
  const LeftPanelSelectButton({
    void Function()? this.onTap = null,
    Icon? this.icon = null,
    required String this.tipText,
    required bool this.isSelected,
    bool this.isTipOrGroupName = false,
    Key? key,
  }) : super(key: key);

  final void Function()? onTap;
  final Icon? icon;
  final String tipText;
  final bool isSelected;
  final int leftPanelHeight =
      56; // be sure that (left panel height)/2 is an even number, or program will run into some problems.
  final isTipOrGroupName;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: leftPanelHeight.toDouble(),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(leftPanelHeight / 2)),
        child: InkWell(
          borderRadius: BorderRadius.circular(leftPanelHeight / 2),
          onTap: onTap,
          child: Ink(
            decoration: isSelected
                ? BoxDecoration(
                    color: Color.fromARGB(255, 215, 227, 248),
                    borderRadius: BorderRadius.circular(leftPanelHeight / 2))
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(leftPanelHeight / 2)),
            child: Row(children: [
              Center(
                child: Container(
                  child: icon != null ? icon : SizedBox.shrink(),
                  margin: !isTipOrGroupName
                      ? EdgeInsets.only(left: 19, right: 10)
                      : EdgeInsets.only(left: 5),
                ),
              ),
              Center(
                child: Text(
                  tipText,
                  style: TextStyle(
                      color: !isSelected
                          ? Color.fromARGB(255, 67, 71, 78)
                          : Color.fromARGB(255, 16, 28, 43),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              )
            ]),
          ),
        ));
  }
}

class LeftPanelSelectButtonByPanelIdAndIcon extends StatelessWidget {
  const LeftPanelSelectButtonByPanelIdAndIcon({
    Key? key,
    required this.panelId,
    required this.currentSelectedPanelId,
    this.icon = null,
  }) : super(key: key);

  final int panelId;
  final Icon? icon;
  final int currentSelectedPanelId;

  @override
  Widget build(BuildContext context) {
    return LeftPanelSelectButton(
      tipText: PanelName.names[panelId]!,
      isSelected: panelId == currentSelectedPanelId,
      onTap: () => Provider.of<PanelSelectionModel>(context, listen: false)
          .setSelectedPanel(panelId),
      icon: icon,
    );
  }
}

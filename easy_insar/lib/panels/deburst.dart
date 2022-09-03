import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/deburst_widgets.dart';
import 'package:flutter/material.dart';

class DeburstPanelWidget extends StatelessWidget {
  const DeburstPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [DeburstImageSelectWidget(), DeburstButton()],
        ),
      ],
    ));
  }
}

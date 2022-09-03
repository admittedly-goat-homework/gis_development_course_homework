import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:flutter/material.dart';

class CreateInterferogramPanelWidget extends StatelessWidget {
  const CreateInterferogramPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [
            CreateInterferogramImageSelectWidget(),
            CreateInterferogramButton()
          ],
        ),
      ],
    ));
  }
}

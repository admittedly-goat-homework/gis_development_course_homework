import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/multilooking_widgets.dart';
import 'package:flutter/material.dart';

class MultilookingPanelWidget extends StatelessWidget {
  const MultilookingPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [MultilookingImageSelectWidget(),MultilookingTimesSelectWidget(), MultilookingButton()],
        ),
      ],
    ));
  }
}

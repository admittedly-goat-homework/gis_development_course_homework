import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/phase_to_displacement_widgets.dart';
import 'package:flutter/material.dart';

class PhaseToDisplacementPanelWidget extends StatelessWidget {
  const PhaseToDisplacementPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [PhaseToDisplacementImageSelectWidget(), PhaseToDisplacementButton()],
        ),
      ],
    ));
  }
}

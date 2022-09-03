import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/phase_unwrapping_widgets.dart';
import 'package:flutter/material.dart';

class PhaseUnwrappingPanelWidget extends StatelessWidget {
  const PhaseUnwrappingPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [PhaseUnwrappingImageSelectWidget(), PhaseUnwrappingButton()],
        ),
      ],
    ));
  }
}

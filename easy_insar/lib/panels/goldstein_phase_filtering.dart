import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/goldstein_phase_filtering_widgets.dart';
import 'package:flutter/material.dart';

class GoldsteinPhaseFilteringPanelWidget extends StatelessWidget {
  const GoldsteinPhaseFilteringPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [GoldsteinPhaseFilteringImageSelectWidget(), GoldsteinPhaseFilteringButton()],
        ),
      ],
    ));
  }
}

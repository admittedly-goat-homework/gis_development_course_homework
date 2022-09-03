import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/phase_to_displacement_widgets.dart';
import 'package:easy_insar/widgets/range_doppler_terrain_correction_widgets.dart';
import 'package:flutter/material.dart';

class RangeDopplerTerrainCorrectionPanelWidget extends StatelessWidget {
  const RangeDopplerTerrainCorrectionPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [RangeDopplerTerrainCorrectionImageSelectWidget(), RangeDopplerTerrainCorrectionButton()],
        ),
      ],
    ));
  }
}

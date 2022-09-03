import 'package:easy_insar/widgets/create_interferogram_widgets.dart';
import 'package:easy_insar/widgets/topographic_phase_removal_widgets.dart';
import 'package:flutter/material.dart';

class TopographicPhaseRemovalPanelWidget extends StatelessWidget {
  const TopographicPhaseRemovalPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [
            TopographicPhaseRemovalImageSelectWidget(),
            TopographicPhaseRemovalButton()
          ],
        ),
        Text(
            '\nUsing SRTM-1 data to remove topo phase. It is currently one of the best publicly accessible DEM data available, and can be downloaded automatically.')
      ],
    ));
  }
}

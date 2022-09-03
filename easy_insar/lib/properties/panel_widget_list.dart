import 'package:easy_insar/panels/about.dart';
import 'package:easy_insar/panels/coregistration.dart';
import 'package:easy_insar/panels/create_interferogram.dart';
import 'package:easy_insar/panels/deburst.dart';
import 'package:easy_insar/panels/download_list.dart';
import 'package:easy_insar/panels/goldstein_phase_filtering.dart';
import 'package:easy_insar/panels/guidance_of_easy_insar.dart';
import 'package:easy_insar/panels/multilooking.dart';
import 'package:easy_insar/panels/phase_to_displacement.dart';
import 'package:easy_insar/panels/phase_unwrapping.dart';
import 'package:easy_insar/panels/principles_of_insar.dart';
import 'package:easy_insar/panels/range_doppler_terrain_correction.dart';
import 'package:easy_insar/panels/select_and_download_data.dart';
import 'package:easy_insar/panels/topographic_phase_removal.dart';
import 'package:easy_insar/panels/welcome_page.dart';
import 'package:easy_insar/panels/workspace.dart';
import 'package:flutter/material.dart';

class PanelWidgets {
  static var panelWidgetList = <int, Widget>{
    0: WelcomePage(),
    1: PrinciplesOfInSAR(),
    2: GuidanceToEasyInSAR(),
    3: SelectAndDownloadData(),
    4: CoregistrationPanelWidget(),
    5: CreateInterferogramPanelWidget(),
    6: DeburstPanelWidget(),
    7: TopographicPhaseRemovalPanelWidget(),
    8: MultilookingPanelWidget(),
    9: GoldsteinPhaseFilteringPanelWidget(),
    10: PhaseUnwrappingPanelWidget(),
    11: PhaseToDisplacementPanelWidget(),
    12: RangeDopplerTerrainCorrectionPanelWidget(),
    14: DownloadListPanelWidet(),
    15:WorkspacePanelWidet(),
    16:AboutPanelWidget()
  };
}

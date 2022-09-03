import 'package:easy_insar/models/coregistration_model.dart';
import 'package:easy_insar/widgets/coregistration_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoregistrationPanelWidget extends StatelessWidget {
  const CoregistrationPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoregistrationCommitData(),
      child: Column(children: [
        ChangeNotifierProvider(
          create: (context) => CoregistrationMapModel(),
          child: Row(
            children: [
              CoregistrationImageSelectBoxWidget(
                isMaster: true,
              ),
              CoregistrationAreaSelectBoxWidget(
                isMaster: true,
              ),
              CoregistrationImageMapWidget()
            ],
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CoregistrationMapModel(),
          child: Row(children: [
            CoregistrationImageSelectBoxWidget(
              isMaster: false,
            ),
            CoregistrationAreaSelectBoxWidget(
              isMaster: false,
            ),
            CoregistrationImageMapWidget()
          ]),
        ),
        Row(
          children: [Expanded(child: Container()), CoregistrationButton()],
        )
      ]),
    );
  }
}

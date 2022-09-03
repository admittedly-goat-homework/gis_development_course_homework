import 'package:easy_insar/models/select_and_download_file_list.dart';
import 'package:easy_insar/widgets/select_and_download_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class SelectAndDownloadData extends StatelessWidget {
  const SelectAndDownloadData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => SatelliteDownloadSelectBoxModel()),
      child: ChangeNotifierProvider(
        create: ((context) => SatelliteDownloadInfoModel()),
        child: Container(
          child: Row(children: [
            Expanded(
              child: Container(
                  padding:
                      EdgeInsets.only(left: 19, right: 0, top: 19, bottom: 19),
                  child: DownloadSelectMap()),
            ),
            SizedBox(
              width: 312 + 19 * 2,
              child: Container(
                  padding: EdgeInsets.all(19),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Color.fromARGB(255, 227, 235, 245)),
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Select and download',
                              style: TextStyle(fontSize: 24),
                            )),
                        Expanded(
                          child: SelectAndDownloadListViewSatelliteImages(),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SearchButtonWidget(),
                            SizedBox(
                              width: 10,
                            ),
                            DownloadButtonSelectAndDownload(),
                          ],
                        ),
                        Container(
                          child: Text(
                            'Advanced query params: SLC IW Sentinel-1',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color.fromARGB(255, 193, 202, 213)),
                          ),
                          padding: EdgeInsets.only(bottom: 19, top: 10),
                        )
                      ],
                    ),
                  )),
            )
          ]),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:easy_insar/models/select_and_download_file_list.dart';
import 'package:easy_insar/properties/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

late final MapController downloadMapController;
bool isAlreadyDownloaded = false;

class SingleImageSelectboxEntry extends StatelessWidget {
  SingleImageSelectboxEntry(
      {required int this.id,
      required String this.timeString,
      required this.size,
      required this.isSelected,
      required this.isViewing,
      Key? key})
      : super(key: key);

  final int id;
  final String timeString;
  final String size;
  final bool isSelected;
  final bool isViewing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12),
      child: Material(
        color: isViewing
            ? Color.fromARGB(255, 159, 201, 255)
            : Color.fromARGB(255, 227, 235, 245), // the color of background
        borderRadius: BorderRadius.circular(57 / 2),
        child: InkWell(
          onTap: () {
            Provider.of<SatelliteDownloadInfoModel>(context, listen: false)
                .changeViewingId(id);
          },
          borderRadius: BorderRadius.circular(57 / 2),
          child: Ink(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.only(left: 24, right: 24),
              child: SizedBox(
                height: 57,
                child: Center(
                    child: Row(
                  children: [
                    Text(timeString),
                    Expanded(
                      child: Container(),
                    ),
                    Text(size),
                    Container(padding: EdgeInsets.only(right: 19)),
                    Checkbox(
                        value: isSelected,
                        onChanged: (_) {
                          Provider.of<SatelliteDownloadInfoModel>(context,
                                  listen: false)
                              .switchSelected(id);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)))
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectAndDownloadListViewSatelliteImages extends StatelessWidget {
  const SelectAndDownloadListViewSatelliteImages({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SatelliteDownloadInfoModel imageList =
        Provider.of<SatelliteDownloadInfoModel>(context);
    List<Widget> children = [];
    for (SingleSatelliteDownloadEntry i in imageList.getAllEntries()) {
      children.add(SingleImageSelectboxEntry(
          id: i.id,
          timeString: i.timeString,
          size: i.size,
          isSelected: i.isSelected,
          isViewing: i.id == imageList.viewingId));
    }

    return ListView(
      controller: ScrollController(),
      children: children,
    );
  }
}

class SearchButtonWidget extends StatefulWidget {
  SearchButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchButtonWidget> createState() => _SearchButtonWidgetState();
}

class _SearchButtonWidgetState extends State<SearchButtonWidget> {
  bool _isDisabled = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isDisabled
          ? null
          : () async {
              if (isAlreadyDownloaded) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'This application is designed for processing only one scene area. If you want advanced process or want to process multiple areas, please use SNAP application or other more specialized apps.')));
                return;
              }
              if (!Provider.of<SatelliteDownloadSelectBoxModel>(context,
                      listen: false)
                  .isFinishedDrawingPolygon) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please draw a rectangle first.')));
                return;
              }
              setState(() {
                _isDisabled = true;
              });
              SatelliteDownloadSelectBoxModel downloadSelectBoxModel =
                  Provider.of<SatelliteDownloadSelectBoxModel>(context,
                      listen: false);
              final response = await http.get(Uri.parse(APIEndpoint
                  .selectAndDownload
                  .replaceAll(
                      '{bounding_x1}', downloadSelectBoxModel.lowX.toString())
                  .replaceAll(
                      '{bounding_y1}', downloadSelectBoxModel.lowY.toString())
                  .replaceAll(
                      '{bounding_x2}', downloadSelectBoxModel.lowX.toString())
                  .replaceAll(
                      '{bounding_y2}', downloadSelectBoxModel.maxY.toString())
                  .replaceAll(
                      '{bounding_x3}', downloadSelectBoxModel.maxX.toString())
                  .replaceAll(
                      '{bounding_y3}', downloadSelectBoxModel.maxY.toString())
                  .replaceAll(
                      '{bounding_x4}', downloadSelectBoxModel.maxX.toString())
                  .replaceAll('{bounding_y4}',
                      downloadSelectBoxModel.lowY.toString())));
              var responseJson = jsonDecode(response.body);
              SatelliteDownloadInfoModel internalData =
                  Provider.of<SatelliteDownloadInfoModel>(context,
                      listen: false);
              internalData.clearEntry();
              for (var i in responseJson) {
                internalData.addEntry(
                    i['id'],
                    i['timeString'],
                    i['size'],
                    false,
                    i['x1'],
                    i['y1'],
                    i['x2'],
                    i['y2'],
                    i['x3'],
                    i['y3'],
                    i['x4'],
                    i['y4']);
              }
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Search complete.')));
              setState(() {
                _isDisabled = false;
              });
            },
      child: SizedBox(
        width: 25,
        height: 56,
        child: Container(
          child: Icon(
            Icons.search_rounded,
            color: Color.fromARGB(255, 6, 6, 7),
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
          minimumSize: Size(10, 56),
          primary: Color.fromARGB(255, 209, 228, 255),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}

class DownloadButtonSelectAndDownload extends StatefulWidget {
  const DownloadButtonSelectAndDownload({
    Key? key,
  }) : super(key: key);

  @override
  State<DownloadButtonSelectAndDownload> createState() =>
      _DownloadButtonSelectAndDownloadState();
}

class _DownloadButtonSelectAndDownloadState
    extends State<DownloadButtonSelectAndDownload> {
  bool _isDisabled = false;
  void _onPressed() async {
    if (isAlreadyDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'This application is designed for downloading once of all images. If you want advanced process or want to process multiple areas, please use SNAP application or other more specialized apps.')));
      return;
    }
    setState(() {
      _isDisabled = true;
    });
    SatelliteDownloadInfoModel model =
        Provider.of<SatelliteDownloadInfoModel>(context, listen: false);
    List<int> selectedIds = model.getAllSelectedId();
    String queryString = '';
    for (int i in selectedIds) {
      queryString += i.toString() + ':';
    }
    if (queryString.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You haven\'t selected one image!')));
      setState(() {
        _isDisabled = false;
      });
      return;
    }
    queryString = queryString.substring(0, queryString.length - 1);
    final response = await http.get(Uri.parse(APIEndpoint.downloadSelectedImage
        .replaceAll('{id_list}', queryString)));
    final responseString = response.body;
    if (jsonDecode(responseString)['result'] == 'success') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Download started.')));
    }
    setState(() {
      _isDisabled = false;
      isAlreadyDownloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isDisabled ? null : _onPressed,
      child: SizedBox(
        width: 25,
        height: 56,
        child: Container(
          child: Icon(
            Icons.file_download_outlined,
            color: Color.fromARGB(255, 6, 6, 7),
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
          minimumSize: Size(10, 56),
          primary: Color.fromARGB(255, 209, 228, 255),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}

class DownloadSelectMap extends StatefulWidget {
  const DownloadSelectMap({
    Key? key,
  }) : super(key: key);

  @override
  State<DownloadSelectMap> createState() => _DownloadSelectMapState();
}

class _DownloadSelectMapState extends State<DownloadSelectMap> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<Polyline> _polylines = [];
  List<Polyline> _selectPolylines = [];
  List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<SatelliteDownloadInfoModel>(
      builder: (context, downloadInfo, child) {
        _polylines = [];
        for (var i in downloadInfo.getAllEntries()) {
          if (i.id != downloadInfo.viewingId) {
            _polylines.add(Polyline(
              points: [
                LatLng(i.position.y1, i.position.x1),
                LatLng(i.position.y2, i.position.x2),
                LatLng(i.position.y3, i.position.x3),
                LatLng(i.position.y4, i.position.x4),
                LatLng(i.position.y1, i.position.x1),
              ],
              color: i.id == downloadInfo.viewingId ? Colors.red : Colors.blue,
              strokeWidth: i.id == downloadInfo.viewingId ? 3 : 1,
            ));
          }
        }
        for (var i in downloadInfo.getAllEntries()) {
          if (i.id == downloadInfo.viewingId) {
            _polylines.add(Polyline(
              points: [
                LatLng(i.position.y1, i.position.x1),
                LatLng(i.position.y2, i.position.x2),
                LatLng(i.position.y3, i.position.x3),
                LatLng(i.position.y4, i.position.x4),
                LatLng(i.position.y1, i.position.x1),
              ],
              color: i.id == downloadInfo.viewingId ? Colors.red : Colors.blue,
              strokeWidth: i.id == downloadInfo.viewingId ? 3 : 1,
            ));
          }
        }
        return FlutterMap(
          options: MapOptions(
              center: LatLng(0, 0),
              zoom: 2,
              onTap: (TapPosition tapPosition, LatLng location) {
                SatelliteDownloadSelectBoxModel downloadSelectBoxModel =
                    Provider.of<SatelliteDownloadSelectBoxModel>(context,
                        listen: false);
                // finished drawing previously, including first run
                if (((downloadSelectBoxModel.firstPointSelected == true) &
                        (downloadSelectBoxModel.isFinishedDrawingPolygon ==
                            true)) |
                    ((downloadSelectBoxModel.firstPointSelected == false) &
                        (downloadSelectBoxModel.isFinishedDrawingPolygon ==
                            false))) {
                  downloadSelectBoxModel.resetPosition();
                  _markers = [];
                  _selectPolylines = [];
                  downloadSelectBoxModel.isFinishedDrawingPolygon = false;
                  downloadSelectBoxModel.firstPointSelected = true;
                  _markers.add(Marker(
                      point: location,
                      builder: (context) => Icon(
                            Icons.room_rounded,
                            color: Colors.yellowAccent.shade700,
                          )));
                  downloadSelectBoxModel.lowX =
                      min(downloadSelectBoxModel.lowX, location.longitude);
                  downloadSelectBoxModel.lowY =
                      min(downloadSelectBoxModel.lowY, location.latitude);
                  downloadSelectBoxModel.maxX =
                      max(downloadSelectBoxModel.maxX, location.longitude);
                  downloadSelectBoxModel.maxY =
                      max(downloadSelectBoxModel.maxY, location.latitude);
                }
                // first point selected, need to select second point
                else if ((downloadSelectBoxModel.firstPointSelected == true) &
                    (downloadSelectBoxModel.isFinishedDrawingPolygon ==
                        false)) {
                  downloadSelectBoxModel.isFinishedDrawingPolygon = true;
                  _markers = [];
                  downloadSelectBoxModel.lowX =
                      min(downloadSelectBoxModel.lowX, location.longitude);
                  downloadSelectBoxModel.lowY =
                      min(downloadSelectBoxModel.lowY, location.latitude);
                  downloadSelectBoxModel.maxX =
                      max(downloadSelectBoxModel.maxX, location.longitude);
                  downloadSelectBoxModel.maxY =
                      max(downloadSelectBoxModel.maxY, location.latitude);
                  _selectPolylines.add(Polyline(
                    points: [
                      LatLng(downloadSelectBoxModel.lowY,
                          downloadSelectBoxModel.lowX),
                      LatLng(downloadSelectBoxModel.maxY,
                          downloadSelectBoxModel.lowX),
                      LatLng(downloadSelectBoxModel.maxY,
                          downloadSelectBoxModel.maxX),
                      LatLng(downloadSelectBoxModel.lowY,
                          downloadSelectBoxModel.maxX),
                      LatLng(downloadSelectBoxModel.lowY,
                          downloadSelectBoxModel.lowX),
                    ],
                    color: Colors.yellowAccent.shade700,
                    strokeWidth: 3,
                  ));
                }
                setState(() {});
              }),
          layers: [
            TileLayerOptions(
              urlTemplate:
                  "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
              attributionBuilder: (_) {
                return Text("Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community");
              },
            ),
            MarkerLayerOptions(markers: _markers),
            PolylineLayerOptions(
              polylineCulling: false,
              polylines: _selectPolylines,
            ),
            PolylineLayerOptions(
              polylineCulling: false,
              polylines: _polylines,
            ),
          ],
        );
      },
    );
  }
}

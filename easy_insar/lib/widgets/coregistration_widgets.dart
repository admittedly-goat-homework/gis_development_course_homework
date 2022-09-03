import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:easy_insar/models/coregistration_model.dart';
import 'package:easy_insar/properties/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CoregistrationImageSelectBoxWidget extends StatefulWidget {
  CoregistrationImageSelectBoxWidget({required this.isMaster, Key? key})
      : super(key: key);

  bool isMaster;

  @override
  State<CoregistrationImageSelectBoxWidget> createState() =>
      _CoregistrationImageSelectBoxWidgetState();
}

class _CoregistrationImageSelectBoxWidgetState
    extends State<CoregistrationImageSelectBoxWidget> {
  bool _isMaster = false;
  String? dropdownValue = null;
  bool isInit = false; // indicates whether data is fetched from server
  List<SingleImageModel> allImages = [];

  void getAllImages() async {
    var response = await http.get(Uri.parse(APIEndpoint.coregImageFetch));
    var data = jsonDecode(response.body);
    for (var i in data) {
      allImages.add(SingleImageModel(
          id: i['id'],
          timeStamp: i['timeStamp'],
          x1: i['x1'],
          y1: i['y1'],
          x2: i['x2'],
          y2: i['y2'],
          x3: i['x3'],
          y3: i['y3'],
          x4: i['x4'],
          y4: i['y4']));
    }
    isInit = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllImages();
  }

  @override
  Widget build(BuildContext context) {
    _isMaster = widget.isMaster;
    return Expanded(
      flex: 100,
      child: Container(
        margin: EdgeInsets.only(left: 16),
        child: InputDecorator(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10)),
          child: DropdownButton<String>(
              isExpanded: true,
              value: dropdownValue,
              elevation: 4,
              underline: Container(
                height: 2,
              ),
              onChanged: !isInit
                  ? null
                  : (String? newValue) {
                      var model = Provider.of<CoregistrationMapModel>(context,
                          listen: false);
                      var image = allImages.firstWhere(
                          (element) => element.timeStamp == newValue);
                      if (_isMaster) {
                        Provider.of<CoregistrationCommitData>(context,
                                listen: false)
                            .master = newValue!;
                      } else {
                        Provider.of<CoregistrationCommitData>(context,
                                listen: false)
                            .slave = newValue!;
                      }
                      model.x1 = image.x1;
                      model.y1 = image.y1;
                      model.x2 = image.x2;
                      model.y2 = image.y2;
                      model.x3 = image.x3;
                      model.y3 = image.y3;
                      model.x4 = image.x4;
                      model.y4 = image.y4;
                      model.isInit = true;
                      model.updateExtent();
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
              items: isInit
                  ? allImages
                      .map<DropdownMenuItem<String>>((SingleImageModel value) {
                      return DropdownMenuItem<String>(
                        value: value.MyToString(),
                        child: Text(value.MyToString()!),
                      );
                    }).toList()
                  : [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text(''),
                      )
                    ]),
        ),
      ),
    );
  }
}

class CoregistrationAreaSelectBoxWidget extends StatefulWidget {
  CoregistrationAreaSelectBoxWidget({required this.isMaster, Key? key})
      : super(key: key);
  bool isMaster;
  @override
  State<CoregistrationAreaSelectBoxWidget> createState() =>
      _CoregistrationAreaSelectBoxWidgetState();
}

class _CoregistrationAreaSelectBoxWidgetState
    extends State<CoregistrationAreaSelectBoxWidget> {
  bool _isMaster = false;
  String? dropdownValue = null;
  bool isInit = true; // indicates whether data is fetched from server

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _isMaster = widget.isMaster;
    return Expanded(
      flex: 63,
      child: Container(
        margin: EdgeInsets.all(16),
        child: InputDecorator(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10)),
          child: DropdownButton<String>(
            isExpanded: true,
            value: dropdownValue,
            elevation: 4,
            underline: Container(
              height: 2,
            ),
            onChanged: !isInit
                ? null
                : (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                      if (_isMaster) {
                        Provider.of<CoregistrationCommitData>(context,
                                listen: false)
                            .masterSwath = newValue;
                      } else {
                        Provider.of<CoregistrationCommitData>(context,
                                listen: false)
                            .slaveSwath = newValue;
                      }
                    });
                  },
            items: <String>['IW1', 'IW2', 'IW3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class CoregistrationImageMapWidget extends StatefulWidget {
  const CoregistrationImageMapWidget({Key? key}) : super(key: key);

  @override
  State<CoregistrationImageMapWidget> createState() =>
      _CoregistrationImageMapWidgetState();
}

class _CoregistrationImageMapWidgetState
    extends State<CoregistrationImageMapWidget> {
  MapController _controller = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CoregistrationMapModel>(builder: (context, model, child) {
      List<Polyline> _selectPolylines = [];
      if (model.isInit) {
        _selectPolylines.add(Polyline(points: [
          LatLng(model.y1!, model.x1!),
          LatLng(model.y2!, model.x2!),
          LatLng(model.y3!, model.x3!),
          LatLng(model.y4!, model.x4!),
          LatLng(model.y1!, model.x1!),
        ], color: Colors.red, strokeWidth: 3));
      }
      return Expanded(
        flex: 92,
        child: Container(
            margin: EdgeInsets.only(right: 16, top: 20),
            child: SizedBox(
                height: 200,
                child: Container(
                  child: FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                      center: !model.isInit
                          ? LatLng(0, 0)
                          : LatLng((model.y1! + model.y4!) / 2,
                              (model.x1! + model.x4!) / 2),
                      zoom: !model.isInit ? 0.5 : 3.0,
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                        attributionBuilder: (_) {
                          return Text("Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community");
                        },
                      ),
                      PolylineLayerOptions(
                        polylineCulling: false,
                        polylines: _selectPolylines,
                      ),
                      MarkerLayerOptions(
                          markers: model.isInit
                              ? [
                                  Marker(
                                      point: LatLng((model.y1! + model.y4!) / 2,
                                          (model.x1! + model.x4!) / 2),
                                      builder: (context) => Icon(
                                            Icons.room_rounded,
                                            color: Colors.yellowAccent.shade700,
                                          ))
                                ]
                              : [])
                    ],
                  ),
                ))),
      );
    });
  }
}

class CoregistrationButton extends StatefulWidget {
  const CoregistrationButton({
    Key? key,
  }) : super(key: key);

  @override
  State<CoregistrationButton> createState() => _CoregistrationButtonState();
}

class _CoregistrationButtonState extends State<CoregistrationButton> {
  bool _isRunning = false;
  void _commitAllData() async {
    setState(() {
      _isRunning = true;
    });
    if (Provider.of<CoregistrationCommitData>(context, listen: false).isInit ==
        false) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select image and swath.')));
      setState(() {
        _isRunning = false;
      });
      return;
    } else {
      final response = await http.get(Uri.parse(APIEndpoint.coregSubmit
          .replaceAll(
              '{master}',
              Provider.of<CoregistrationCommitData>(context, listen: false)
                  .master)
          .replaceAll(
              '{slave}',
              Provider.of<CoregistrationCommitData>(context, listen: false)
                  .slave)
          .replaceAll(
              '{master_swath}',
              Provider.of<CoregistrationCommitData>(context, listen: false)
                  .masterSwath)
          .replaceAll(
              '{slave_swath}',
              Provider.of<CoregistrationCommitData>(context, listen: false)
                  .slaveSwath)));
      final responseString = response.body;
      if (jsonDecode(responseString)['result'] == 'success') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Coregistration started.')));
      }
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: Size(10, 56),
              primary: Color.fromARGB(255, 209, 228, 255),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          onPressed: _isRunning ? null : _commitAllData,
          child: Row(
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: Color.fromARGB(255, 6, 6, 7),
              ),
              Text('  Run  ',
                  style: TextStyle(
                    color: Color.fromARGB(255, 6, 6, 7),
                  )),
            ],
          )),
    );
  }
}

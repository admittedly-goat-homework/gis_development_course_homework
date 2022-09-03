import 'dart:convert';
import 'package:easy_insar/properties/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:easy_insar/properties/test_param.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkspacePanelWidet extends StatefulWidget {
  WorkspacePanelWidet({Key? key}) : super(key: key);

  @override
  State<WorkspacePanelWidet> createState() => _WorkspacePanelWidetState();
}

class _WorkspacePanelWidetState extends State<WorkspacePanelWidet> {
  List<WorkspaceEntry> downloadEntries = [];
  bool isRefreshButtonDisabled = false;

  void deleteById(int id) async {
    final response = await http.get(Uri.parse(
        APIEndpoint.downloadSelectedImage.replaceAll('{id}', id.toString())));
    final responseString = response.body;
    getInfoFromServer();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Deletion complete. Loading new list...'),
    ));
  }

  void getInfoFromServer() async {
    setState(() {
      isRefreshButtonDisabled = true;
      downloadEntries = [];
    });
    final response = await http.get(Uri.parse(APIEndpoint.getWorkspaceItems));
    final responseString = response.body;
    setState(() {
      for (var i in jsonDecode(responseString)) {
        downloadEntries.add(WorkspaceEntry(
          name: i['name'],
          type: i['type'],
          id: i['id'],
          tiffUrl: i['tiffUrl'],
          isDone: i['isDone'],
          size: i['size'],
          deleteFunction: () {
            deleteById(i['id']);
          },
          extentImageBase64: i['extentImageBase64'],
        ));
      }
      isRefreshButtonDisabled = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getInfoFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      ListView(
          children: List.from(downloadEntries.map((e) => Center(
                child: e,
              )))),
      Row(
        children: [
          Expanded(child: Container()),
          Column(
            children: [
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                    onPressed: isRefreshButtonDisabled
                        ? null
                        : () {
                            getInfoFromServer();
                          },
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Color.fromARGB(255, 6, 6, 7),
                    ),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(10, 56),
                        primary: Color.fromARGB(255, 209, 228, 255),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)))),
              )
            ],
          )
        ],
      )
    ]));
  }
}

class WorkspaceEntry extends StatefulWidget {
  WorkspaceEntry(
      {required this.name,
      required this.type,
      required this.id,
      required this.tiffUrl,
      required this.isDone,
      required this.extentImageBase64,
      required this.deleteFunction,
      required this.size,
      Key? key})
      : super(key: key);

  String name;
  String type;
  int id;
  String tiffUrl;
  String size;
  bool isDone;
  String extentImageBase64;
  var deleteFunction;

  @override
  State<WorkspaceEntry> createState() => _WorkspaceEntryState();
}

class _WorkspaceEntryState extends State<WorkspaceEntry> {
  bool _isDisabledButton = false;

  void _launchURL() async {
    if (await canLaunchUrl(Uri.parse(widget.tiffUrl))) {
      await launchUrl(Uri.parse(widget.tiffUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDisabledButton = widget.isDone ? false : true;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: SizedBox(
        width: 461,
        height: 147,
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 223, 226, 235),
              borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular((12)),
            child: Row(children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              widget.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(child: Container())
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(children: [
                          Text(
                            widget.type,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 10),
                          Text(widget.size,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                      Row(
                        children: [
                          Text(widget.isDone ? '✅Complete' : '🕑Processing',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          Expanded(child: Container())
                        ],
                      ),
                      Expanded(child: Container()),
                      Row(
                        children: [
                          TextButton(
                              onPressed: _isDisabledButton
                                  ? null
                                  : () {
                                      _launchURL();
                                    },
                              style: TextButton.styleFrom(
                                  primary: Color.fromARGB(255, 15, 96, 164)),
                              child: Text('Download Tiff')),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Column(
                        children: [
                          Icon(widget.isDone
                              ? Icons.check
                              : Icons.access_time_rounded),
                          Expanded(child: Container())
                        ],
                      ),
                    ],
                  )
                ]),
              )),
              Image.memory(base64Decode(widget.extentImageBase64))
            ]),
          ),
        ),
      ),
    );
  }
}

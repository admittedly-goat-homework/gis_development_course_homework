import 'dart:convert';
import 'package:easy_insar/properties/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:easy_insar/properties/test_param.dart';
import 'package:flutter/material.dart';

class DownloadListPanelWidet extends StatefulWidget {
  DownloadListPanelWidet({Key? key}) : super(key: key);

  @override
  State<DownloadListPanelWidet> createState() => _DownloadListPanelWidetState();
}

class _DownloadListPanelWidetState extends State<DownloadListPanelWidet> {
  List<DownloadEntry> downloadEntries = [];

  void cancelDownloadByTimeStamp(String timeStamp) async {
    final response = await http.get(Uri.parse(APIEndpoint.downloadSelectedImage
        .replaceAll('{time_stamp}', timeStamp)));
    final responseString = response.body;
    getInfoFromServer();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Deletion complete. Loading new list...'),
    ));
  }

  void getInfoFromServer() async {
    setState(() {
      downloadEntries = [];
    });
    final response =
        await http.get(Uri.parse(APIEndpoint.currentDownloadingItems));
    final responseString = response.body;
    setState(() {
      for (var i in jsonDecode(responseString)) {
        downloadEntries.add(DownloadEntry(
            timeStamp: i['timeStamp'],
            downloadSize: i['downloadSize'],
            percentageDownloaded: i['percentageDownloaded'].toDouble(),
            isDownloaded: i['isDownloaded'],
            imageBase64: i['imageBase64'],
            cancelFunction: () {
              cancelDownloadByTimeStamp(i['timeStamp']);
            }));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
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
                    onPressed: () {
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

class DownloadEntry extends StatefulWidget {
  DownloadEntry(
      {required this.timeStamp,
      required this.downloadSize,
      required this.percentageDownloaded,
      required this.isDownloaded,
      required this.imageBase64,
      required this.cancelFunction,
      Key? key})
      : super(key: key);

  String timeStamp;
  String downloadSize; // 1.7/3.6G
  double percentageDownloaded; // for example, 0.5. A value between 0 and 1.
  bool isDownloaded;
  String
      imageBase64; // base64 encoded image, don't need data:image/png;base64 prefix.
  var cancelFunction;

  @override
  State<DownloadEntry> createState() => _DownloadEntryState();
}

class _DownloadEntryState extends State<DownloadEntry> {
  bool _isDisabledButton = false;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            widget.timeStamp,
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
                          !widget.isDownloaded ? 'Downloading' : 'Downloaded',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Text(widget.downloadSize,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: LinearProgressIndicator(
                        value: widget.percentageDownloaded,
                        color: Color.fromARGB(255, 159, 201, 255),
                        backgroundColor: Color.fromARGB(255, 253, 252, 255),
                      ),
                    ),
                    Row(
                      children: [
                        Text('IW SLC Sentinel-1A',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 190, 194, 204))),
                        Expanded(child: Container())
                      ],
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              )),
              Image.memory(base64Decode(widget.imageBase64))
            ]),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:easy_insar/properties/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String __imageId = '';

class PhaseUnwrappingImageSelectWidget extends StatefulWidget {
  PhaseUnwrappingImageSelectWidget({Key? key}) : super(key: key);

  @override
  State<PhaseUnwrappingImageSelectWidget> createState() =>
      _PhaseUnwrappingImageSelectWidgetState();
}

class _PhaseUnwrappingImageSelectWidgetState
    extends State<PhaseUnwrappingImageSelectWidget> {
  String? dropdownValue;
  bool isInit = false;
  List<String> allImages = [];

  void getAllImageList() async {
    final response =
        await http.get(Uri.parse(APIEndpoint.phaseUnwrappingImageFetch));
    final responseString = response.body;
    for (var i in jsonDecode(responseString)) {
      allImages.add(i.toString());
    }
    setState(() {
      isInit = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllImageList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21, top: 15),
      child: SizedBox(
        width: 422,
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
                        dropdownValue = newValue;
                        __imageId = newValue!;
                      });
                    },
              items: isInit
                  ? allImages.map<DropdownMenuItem<String>>((var value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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

class PhaseUnwrappingButton extends StatefulWidget {
  const PhaseUnwrappingButton({
    Key? key,
  }) : super(key: key);

  @override
  State<PhaseUnwrappingButton> createState() => _PhaseUnwrappingButtonState();
}

class _PhaseUnwrappingButtonState extends State<PhaseUnwrappingButton> {
  bool _isRunning = false;
  void _commitAllData() async {
    setState(() {
      _isRunning = true;
    });
    if (__imageId == '') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No image selected.')));
    } else {
      final response = await http.get(Uri.parse(APIEndpoint
          .phaseUnwrappingSubmit
          .replaceAll('{image_name}', __imageId)));
      final responseString = response.body;
      if (jsonDecode(responseString)['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phase unwrapping process started.')));
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

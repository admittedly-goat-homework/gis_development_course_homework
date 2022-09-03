import 'package:easy_insar/properties/markdown_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AboutPanelWidget extends StatelessWidget {
  const AboutPanelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(child: Markdown(
    controller: ScrollController(),
    data: AboutMarkdownString.data,),);
  }
}
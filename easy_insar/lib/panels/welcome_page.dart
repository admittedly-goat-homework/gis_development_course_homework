import 'package:easy_insar/properties/markdown_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Markdown(
      controller: ScrollController(),
      data: WelcomePageMarkdownString.data
    ));
  }
}

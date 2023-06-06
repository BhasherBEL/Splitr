import 'dart:ui';

import 'package:flutter/material.dart';

class HeaderTile extends StatelessWidget {
  const HeaderTile(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(
          fontFeatures: [FontFeature.enable('smcp')],
        ),
      ),
      tileColor: Theme.of(context).splashColor,
      dense: false,
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

class HeaderTile extends StatelessWidget {
  const HeaderTile(this.text, {super.key, this.smallCaps = false});

  final String text;
  final bool smallCaps;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(
          fontFeatures: [if (smallCaps) const FontFeature.enable('smcp')],
        ),
      ),
      tileColor: Theme.of(context).splashColor,
      dense: false,
    );
  }
}

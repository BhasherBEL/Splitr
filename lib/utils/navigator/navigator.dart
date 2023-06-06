import 'package:flutter/material.dart';

Future navigatorPush(BuildContext context, Function builder) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => builder(),
    ),
  );
}

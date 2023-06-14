import 'package:flutter/material.dart';

Future<dynamic> confirmBox({
  required BuildContext context,
  required String title,
  required String content,
  required Function()? onValidate,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onValidate,
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('No'),
        ),
      ],
    ),
  );
}

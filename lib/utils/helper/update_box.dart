import 'package:flutter/material.dart';
import 'package:splitr/models/app_data.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<dynamic> updateBox({
  required BuildContext context,
  required String currentVersion,
  required String releaseVersion,
  required String releaseUrl,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New Update Available'),
      content:
          Text('Update from $currentVersion to $releaseVersion is available'),
      actions: [
        ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                AppData.sharedPreferences
                    .setString('last_version', releaseVersion);
                Navigator.of(context).pop();
              },
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () async {
                await launchUrlString(
                  releaseUrl,
                  mode: LaunchMode.externalApplication,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        )
      ],
    ),
  );
}

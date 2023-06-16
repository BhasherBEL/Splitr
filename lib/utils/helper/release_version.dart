import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:splitr/models/app_data.dart';
import 'package:tuple/tuple.dart';

String repository =
    'https://api.github.com/repos/bhasherbel/splitr/releases/latest';

Future<Tuple3<bool, String, String>> checkForNewRelease() async {
  final response = await http.get(Uri.parse(repository));

  if (response.statusCode != 200) {
    return const Tuple3(false, '', '');
  }

  final releaseData = json.decode(response.body);

  String releaseVersion = releaseData['tag_name'] as String;

  String lastChecked = AppData.sharedPreferences.getString('last_version') ??
      (await PackageInfo.fromPlatform()).version;

  if (isNewer(lastChecked, releaseVersion)) {
    String url = releaseData['html_url'] as String;

    return Tuple3(true, releaseVersion, url);
  }

  return const Tuple3(false, '', '');
}

bool isNewer(String old, String new_) {
  final parts1 = old.split('+')[0].split('.');
  final parts2 = new_.split('+')[0].split('.');

  for (int i = 0; i < parts1.length; i++) {
    final int part1 = int.parse(parts1[i]);
    final int part2 = int.parse(parts2[i]);

    if (part1 != part2) {
      return part2 > part1;
    }
  }

  return false;
}

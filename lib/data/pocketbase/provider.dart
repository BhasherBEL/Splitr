import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../models/instance.dart';
import '../../models/item.dart';
import '../../models/project.dart';
import '../provider.dart';
import 'item.dart';
import 'item_part.dart';
import 'participant.dart';
import 'project.dart';

class PocketBaseProvider extends Provider {
  PocketBaseProvider(Project project, Instance instance)
      : super(
          project,
          instance,
        ) {
    pb = PocketBase(instance.data['instance']);
  }

  late PocketBase pb;

  @override
  Future<bool> checkConnection() async {
    HealthCheck hc = await pb.health.check();
    return hc.code == 200;
  }

  @override
  Future<bool> sync() async {
    if (!await checkConnection()) return false;
    await connect();

    await PocketBaseProject.sync(pb, project);
    await PocketBaseParticipant.sync(pb, project);
    await PocketBaseItem.sync(pb, project);
    for (Item item in project.items) {
      await PocketBaseItemPart.sync(pb, item);
    }

    project.lastSync = DateTime.now();
    await project.conn.save();
    return true;
  }

  @override
  Future<bool> connect() async {
    await pb.collection('users').authWithPassword(
          instance.data['username'],
          instance.data['password'],
        );

    final bool isValid = pb.authStore.isValid;
    return isValid;
  }

  @override
  bool hasSync() {
    return true;
  }

  @override
  Future<bool> joinWithTitle() async {
    return await PocketBaseProject.join(pb, project);
  }

  static void onClientException(ClientException e, BuildContext c) {
    String message;

    if (e.statusCode != 0 && e.response.containsKey('message')) {
      message = 'Error ${e.statusCode}: ${e.response['message']}';
    } else if (e.originalError != null) {
      message = e.originalError.toString();
    } else {
      message = e.toString();
    }

    if (c.mounted) {
      ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  static Future<bool> checkCredentials(Instance instance) async {
    if (!instance.data.containsKey('instance') ||
        !instance.data.containsKey('username') ||
        !instance.data.containsKey('password')) {
      return false;
    }

    PocketBase pb = PocketBase(instance.data['instance']);

    await pb.collection('users').authWithPassword(
          instance.data['username'],
          instance.data['password'],
        );

    final bool isValid = pb.authStore.isValid;
    return isValid;
  }
}

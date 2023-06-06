import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../instance.dart';
import '../../item.dart';
import '../../item_part.dart';
import '../../participant.dart';
import '../../project.dart';
import '../local/deleted.dart';
import '../provider.dart';
import 'deleted.dart';
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
    final Map<String, List<String>> deleted =
        await PocketBaseDeleted.checkNewDeleted(pb, project);

    (await LocalDeleted.getSince(project, project.lastSync)).forEach(
      (collection, uids) async {
        for (String uid in uids) {
          await PocketBaseDeleted.delete(pb, project, collection, uid);
          await pb.collection(collection).delete(uid);
        }
      },
    );

    await PocketBaseProject(project, pb).sync();
    for (Participant participant in project.participants) {
      if (participant.remoteId != null &&
          deleted['participants']!.contains(participant.remoteId)) {
        project.participants.remove(participant);
        await participant.conn.delete();
      } else {
        await PocketBaseParticipant(project, participant, pb).pushIfChange();
      }
    }
    await PocketBaseParticipant.checkNews(pb, project);

    for (Item item in project.items) {
      if (item.remoteId != null && deleted['items']!.contains(item.remoteId)) {
        project.items.remove(item);
        await item.conn.delete();
      } else {
        await PocketBaseItem(project, item, pb).pushIfChange();
        for (ItemPart ip in item.itemParts) {
          await PocketBaseItemPart(project, ip, pb).pushIfChange();
        }
      }
    }
    await PocketBaseItem.checkNews(pb, project);

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
    return await PocketBaseProject(project, pb).join();
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

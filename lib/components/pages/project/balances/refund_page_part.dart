import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../model/participant.dart';
import '../../../../model/project.dart';
import '../../../../utils/tiles/header_tile.dart';

List<Widget> getRefundPageTiles({
  required final Project project,
  required final Map<Participant, double> parts,
  required final List<Participant> sortedParticipants,
  required final BuildContext context,
}) {
  bool hasMe = project.currentParticipant != null;

  List<Widget> tiles = [];

  tiles.add(const HeaderTile("How to refund ?"));

  if (hasMe) {
    tiles.add(
      const ListTile(
        title: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Best for me",
          ),
        ),
      ),
    );
    tiles.addAll(
      getRefundsOf(
        project: project,
        participant: project.currentParticipant!,
        parts: parts,
        sortedParticipants: sortedParticipants,
      ),
    );
  }

  tiles.add(
    const ListTile(
      title: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Text(
          "Best for everybody",
        ),
      ),
    ),
  );

  tiles.addAll(
    getRefundsOfEverybody(
      project: project,
      parts: parts,
      sortedParticipants: sortedParticipants,
    ),
  );

  return tiles;
}

List<ListTile> getRefundsOf({
  required final Project project,
  required final Participant participant,
  required final Map<Participant, double> parts,
  required final List<Participant> sortedParticipants,
}) {
  List<Participant> sp = List.from(sortedParticipants);

  List<ListTile> tiles = [];

  double share = parts[participant] ?? 0;

  if (share >= 0) {
    tiles.add(
      const ListTile(
        title: Text("Nothing to refund!"),
        dense: true,
      ),
    );
    return tiles;
  }

  share = -share;

  sp.remove(participant);

  double refounded = 0;

  for (Participant p in sp) {
    double part = min(parts[p] ?? 0, share - refounded);
    refounded += part;

    tiles.add(
      ListTile(
        title: Text("${participant.pseudo} -> ${p.pseudo}"),
        trailing: Text('${part.toStringAsFixed(2)} €'),
        dense: true,
      ),
    );

    if (refounded >= share) break;
  }

  return tiles;
}

List<ListTile> getRefundsOfEverybody({
  required final Project project,
  required Map<Participant, double> parts,
  required List<Participant> sortedParticipants,
}) {
  List<ListTile> tiles = [];

  sortedParticipants = List.from(sortedParticipants);
  parts = Map.from(parts);

  for (Participant participant in sortedParticipants.reversed) {
    double share = parts[participant] ?? 0;

    if (share >= 0) {
      break;
    }

    share = -share;

    double refounded = 0;

    for (Participant p in sortedParticipants) {
      double part = min(parts[p] ?? 0, share - refounded);

      // if (part < 1) continue;
      if (part <= 0) continue;

      parts[p] = parts[p]! - part;
      // if (parts[p]! < 1) parts[p] = 0;

      refounded += part;

      tiles.add(
        ListTile(
          title: Text("${participant.pseudo} -> ${p.pseudo}"),
          trailing: Text('${part.toStringAsFixed(2)} €'),
          dense: true,
        ),
      );

      if (refounded >= share) break;
    }
  }

  if (tiles.isEmpty) {
    tiles.add(
      const ListTile(
        title: Text("Nothing to refund!"),
        dense: true,
      ),
    );
  }

  return tiles;
}

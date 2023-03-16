import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/utils/string.dart';

import '../../model/project.dart';
import '../new_participant.dart';
import '../new_project.dart';

class ProjectsDrawer extends StatefulWidget {
  const ProjectsDrawer(
    this.project, {
    Key? key,
    this.onDrawerCallback,
  }) : super(key: key);

  final Project project;
  final Function()? onDrawerCallback;

  @override
  State<ProjectsDrawer> createState() => _ProjectsDrawerState();
}

class _ProjectsDrawerState extends State<ProjectsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                ScrollConfiguration(
                  behavior: NoGlow(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int i = index - widget.project.participants.length;
                      if (i == 0) {
                        return ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text("Add new participant"),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NewParticipantPage(AppData.current!),
                              ),
                            );
                            setState(() {});
                          },
                        );
                      } else if (i == 1) {
                        return ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text("How to refund ?"),
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    title: Text("How to refund ?"),
                                    children: [
                                      Container(
                                        width: double.maxFinite,
                                        child: Refund(widget.project),
                                      ),
                                    ],
                                  );
                                });
                          },
                        );
                      }
                      Participant participant =
                          widget.project.participants.elementAt(index);
                      double share = (([0.0] +
                                          widget.project.items
                                              .map(
                                                  (e) => e.shareOf(participant))
                                              .toList())
                                      .reduce((a, b) => a + b) *
                                  100)
                              .roundToDouble() /
                          100;
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                                child: Text(participant.pseudo.capitalize())),
                            Text(
                              '$share €',
                              style: TextStyle(
                                color: share > 0
                                    ? Color.fromARGB(255, 76, 175, 80)
                                    : share < 0
                                        ? Color.fromARGB(255, 250, 68, 55)
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: (participant.firstname != null ||
                                participant.lastname != null)
                            ? Text(
                                "${participant.firstname} ${participant.lastname}")
                            : null,
                      );
                    },
                    itemCount: widget.project.participants.length + 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text("Exit project"),
                    onTap: () async {
                      AppData.current = null;
                      Navigator.pop(context);
                      if (widget.onDrawerCallback != null) {
                        widget.onDrawerCallback!();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class Refund extends StatelessWidget {
  Refund(
    this.project, {
    super.key,
  });

  Project project;

  List<Pair<Participant, double>> refundForMe() {
    List<Pair<Participant, double>> toRefund = [];

    List<Pair<Participant, double>> balances = [];
    double remaining = 0;

    for (Participant participant in project.participants) {
      double share =
          ([0.0] + project.items.map((e) => e.shareOf(participant)).toList())
              .reduce((a, b) => a + b);

      if (participant == AppData.me) remaining = -share;

      balances.add(Pair(participant, share));
    }

    balances.sort((a, b) => ((b.b - a.b) * 100).toInt());

    for (Pair<Participant, double> balance in balances) {
      if (remaining <= 0) break;
      if (balance.a == AppData.me) continue;
      double v = min(balance.b, remaining);
      remaining -= v;
      toRefund.add(Pair(balance.a, v));
    }

    return toRefund;
  }

  @override
  Widget build(BuildContext context) {
    List<Pair<Participant, double>> toRefund = refundForMe();

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Pair<Participant, double> refundItem = toRefund.elementAt(index);
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(refundItem.a.pseudo),
              ),
              Expanded(
                child: Text('${(refundItem.b * 100).roundToDouble() / 100} €'),
              )
            ],
          ),
        );
      },
      itemCount: toRefund.length,
    );
  }
}

class NoGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);

  @override
  String toString() {
    return '<$a, $b>';
  }
}

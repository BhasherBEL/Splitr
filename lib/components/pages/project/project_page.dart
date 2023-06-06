import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/components/pages/project/balances/balancing_page_part.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/screens/new_project_screen.dart';

import '../../../model/project.dart';
import 'expenses/new_entry.dart';
import 'expenses/item_list.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage(this.project, {super.key});

  final Project project;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  int pageIndex = 0;
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    pages = [
      ItemList(widget.project),
      BalancingPagePart(widget.project),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 4,
          title: Column(
            children: [
              Text(
                widget.project.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.project.participants.length <= 4
                    ? widget.project.participants
                        .map((e) => e.pseudo)
                        .join(', ')
                    : '${widget.project.participants.length} participants',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            actionMenu(),
          ],
        ),
        body: pages[pageIndex],
        floatingActionButton: pageIndex == 0
            ? MainFloatingActionButton(
                widget.project,
                onDone: () => setState(() {}),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (value) => setState(() {
            pageIndex = value;
          }),
          items: const [
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.bar_chart),
            //   label: "Stats",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Expenses",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows),
              label: "Balances",
            ),
          ],
        ));
  }

  PopupMenuButton<dynamic> actionMenu() {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case 0:
            Share.share(
              'Join my shared project with this link:\nhttps://shared.bhasher.com/join?type=${widget.project.provider.name}&instance=${Uri.encodeComponent(widget.project.provider.getInstance())}&code=${widget.project.code}',
            );
            break;
          case 1:
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewProjectScreen(
                  project: widget.project,
                ),
              ),
            );
            setState(() {});
            break;
          case 3:
            setState(() {
              AppData.current = null;
            });
            break;
        }
      },
      itemBuilder: (context) => [
        buildMenuItem(value: 0, text: "Share", icon: Icons.share),
        buildMenuItem(value: 1, text: "Edit project", icon: Icons.edit),
        // buildMenuItem(value: 2, text: "Settings", icon: Icons.settings),
        buildMenuItem(value: 3, text: "Close", icon: Icons.close),
      ],
    );
  }
}

PopupMenuItem buildMenuItem({
  required final int value,
  required final String text,
  final IconData? icon,
  final bool enabled = true,
}) {
  return PopupMenuItem(
    value: value,
    enabled: enabled,
    child: ListTile(
      leading: Icon(icon),
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        textAlign: TextAlign.left,
      ),
      minLeadingWidth: 0,
      visualDensity: const VisualDensity(horizontal: -4),
      enabled: enabled,
    ),
  );
}

class MainFloatingActionButton extends StatefulWidget {
  const MainFloatingActionButton(
    this.project, {
    super.key,
    this.onDone,
  });

  final Project project;
  final void Function()? onDone;

  @override
  State<MainFloatingActionButton> createState() =>
      _MainFloatingActionButtonState();
}

class _MainFloatingActionButtonState extends State<MainFloatingActionButton> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      openCloseDial: isDialOpen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      overlayOpacity: 0,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.note_add_sharp),
          onTap: () async {},
        ),
        // SpeedDialChild(
        //   child: Icon(Icons.post_add),
        // ),
        if (widget.project.participants.isNotEmpty)
          SpeedDialChild(
            child: const Icon(Icons.add),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewEntryPage(widget.project),
                ),
              );
              if (widget.onDone != null) widget.onDone!();
            },
          ),
      ],
    );
  }
}
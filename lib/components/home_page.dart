import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/components/pages/balancing_page_part.dart';
import 'package:shared/components/projects_list.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/screens/new_project_screen.dart';

import '../model/project.dart';
import 'new_entry.dart';
import 'new_participant.dart';
import 'project/item_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Project? project = AppData.current;
  int pageIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      ItemList(project!),
      BalancingPagePart(project!),
    ];
  }

  void back() {
    project = AppData.current;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    project = AppData.current;
    bool hasProject = project != null;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        centerTitle: true,
        elevation: 4,
        title: Column(
          children: [
            Text(
              hasProject ? project!.name : "Shared",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasProject)
              Text(
                project!.participants.length <= 4
                    ? project!.participants.map((e) => e.pseudo).join(', ')
                    : '${project!.participants.length} participants',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          if (hasProject && project!.code != null)
            PopupMenuButton(
              itemBuilder: (context) => [
                buildMenuItem(
                  text: "Manage users",
                  icon: Icons.person,
                ),
                buildMenuItem(
                  text: "Share",
                  icon: Icons.share,
                  onTap: () {
                    Share.share(
                      'Join my shared project with this code: ${project!.code!}',
                    );
                  },
                ),
                buildMenuItem(
                  text: "Settings",
                  icon: Icons.settings,
                ),
                buildMenuItem(
                  text: "Close",
                  icon: Icons.close,
                  onTap: () {
                    setState(() {
                      AppData.current = null;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
      body: hasProject ? pages[pageIndex] : ProjectsList(() => setState(back)),
      // drawer: hasProject
      //     ? ProjectsDrawer(project!, onDrawerCallback: () => setState(back))
      //     : null,
      floatingActionButton: pageIndex == 0
          ? MainFloatingActionButton(
              project,
              onDone: () => setState(back),
            )
          : null,
      bottomNavigationBar: hasProject
          ? BottomNavigationBar(
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
            )
          : null,
    );
  }
}

PopupMenuItem buildMenuItem({
  required final String text,
  final IconData? icon,
  final bool? enabled,
  final void Function()? onTap,
}) {
  return PopupMenuItem(
    onTap: onTap,
    enabled: enabled ?? onTap != null,
    child: ListTile(
      leading: Icon(icon),
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        textAlign: TextAlign.left,
      ),
      minLeadingWidth: 0,
      visualDensity: const VisualDensity(horizontal: -4),
      enabled: enabled ?? onTap != null,
    ),
  );
}

class MainFloatingActionButton extends StatefulWidget {
  const MainFloatingActionButton(
    this.project, {
    super.key,
    this.onDone,
  });

  final Project? project;
  final void Function()? onDone;

  @override
  State<MainFloatingActionButton> createState() =>
      _MainFloatingActionButtonState();
}

class _MainFloatingActionButtonState extends State<MainFloatingActionButton> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return widget.project != null
        ? SpeedDial(
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
                child: const Icon(Icons.person_add_alt_1_rounded),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewParticipantPage(widget.project!),
                    ),
                  );
                  if (widget.onDone != null) widget.onDone!();
                },
              ),
              // SpeedDialChild(
              //   child: Icon(Icons.post_add),
              // ),
              if (widget.project!.participants.isNotEmpty)
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewEntryPage(widget.project!),
                      ),
                    );
                    if (widget.onDone != null) widget.onDone!();
                  },
                ),
            ],
          )
        : FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewProjectScreen(),
                ),
              );
              if (widget.onDone != null) widget.onDone!();
            },
            tooltip: 'Add new entry',
            child: const Icon(Icons.add),
          );
  }
}

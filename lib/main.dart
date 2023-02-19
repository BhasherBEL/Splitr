import 'package:flutter/material.dart';
import 'package:shared/components/new_project.dart';
import 'package:shared/model/project.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(themeColor),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(themeColor),
            foregroundColor: Colors.white,
          )),
      home: const MyHomePage(),
    );
  }

  int get themeColor => 0xff992722;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              "Berlin Trip",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // fontFeatures: [FontFeature.enable('smcp')],
              ),
            ),
            Text(
              "Arthur, Sandrine, Paul",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      drawer: const ProjectsDrawer(),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class ProjectsDrawer extends StatefulWidget {
  const ProjectsDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<ProjectsDrawer> createState() => _ProjectsDrawerState();
}

class _ProjectsDrawerState extends State<ProjectsDrawer> {
  late List<Project> projects;
  bool isLoading = true;

  Future refreshProjects() async {
    setState(() => isLoading = true);
    projects = await Project.getAllProjects();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    refreshProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Text("loading ...")
                : ListView.builder(
                    itemBuilder: (context, index) {
                      Project project = projects.elementAt(index);
                      return ListTile(
                        title: Text(project.name),
                        onLongPress: () async {
                          final result = await showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                            items: [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text("delete"),
                              ),
                            ],
                          );
                          if (result == 'delete') {
                            await project.delete();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Project ${project.name} deleted"),
                            ));
                          }
                        },
                      );
                    },
                    itemCount: projects.length,
                  ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Add new"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewProjectScreen(),
                      ),
                    ),
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

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../new_project/new_project_page.dart';
import '../../main.dart';
import '../../models/app_data.dart';
import '../../data/pocketbase/provider.dart';
import '../../data/provider.dart';
import '../../models/instance.dart';
import '../../models/project.dart';
import '../../models/project_data.dart';
import '../../widgets/new_screen.dart';
import '../../utils/helper/random.dart';

class NewProjectScreen extends StatelessWidget {
  NewProjectScreen({
    this.first = false,
    this.project,
    this.code,
    this.instance,
    super.key,
  });

  final bool first;
  Project? project;
  final String? code;
  final Instance? instance;

  ProjectData setupData = ProjectData();

  Future onValidate(context, formKey) async {
    bool newProject = project == null;

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      if (newProject) {
        project = Project(
          name: setupData.projectName!,
          code: setupData.join ? null : getRandom(5),
          instance: setupData.instance!,
        );
      } else {
        project!.name = setupData.projectName!;
        project!.provider = Provider.initFromInstance(
          project!,
          setupData.instance!,
        );
      }
      try {
        AppData.current = project;
        await project!.conn.save();
        if (setupData.join) {
          await project!.provider.joinWithTitle();
          await project!.sync();
        }
      } on ClientException catch (e) {
        PocketBaseProvider.onClientException(e, context);
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
        return;
      }
      if (first) {
        AppData.firstRun = false;
        runApp(const MainScreen());
      } else {
        if (context.mounted) {
          if (newProject) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NewProjectScreen(
                  project: project,
                ),
              ),
            );
          } else {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            } else {
              runApp(const MainScreen());
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setupData.instance = instance;
    bool newProject = project == null;

    if (newProject && code != null) {
      setupData.projectName = code;
      setupData.join = true;
    }

    return NewScreen(
      title: first
          ? 'Create your first project!'
          : newProject
              ? 'New project'
              : 'Update project',
      buttonTitle: first
          ? 'Let\'s started'
          : newProject
              ? 'Create'
              : 'Update',
      child: NewProjectPage(
        projectData: setupData,
        project: project,
      ),
      onValidate: onValidate,
    );
  }
}

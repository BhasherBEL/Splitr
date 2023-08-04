import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'new_project_page.dart';
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
  final Project? project;
  final String? code;
  final Instance? instance;

  final ProjectData setupData = ProjectData();

  Future onValidate(context, formKey) async {
    bool isNew = project == null;

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      Project updatedProject;
      if (isNew) {
        updatedProject = Project(
          name: setupData.projectName!,
          code: setupData.join ? null : getRandom(5),
          instance: setupData.instance!,
        );
      } else {
        updatedProject = project!;
        updatedProject.name = setupData.projectName!;
        updatedProject.provider = Provider.initFromInstance(
          updatedProject,
          setupData.instance!,
        );
      }
      try {
        AppData.current = updatedProject;
        await updatedProject.conn.save();
        if (setupData.join) {
          await updatedProject.provider.joinWithTitle();
          await updatedProject.sync();
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (context.mounted) {
          if (isNew) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NewProjectScreen(
                  project: updatedProject,
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
    bool isNew = project == null;

    if (isNew && code != null) {
      setupData.projectName = code;
      setupData.join = true;
    }

    return NewScreen(
      title: first
          ? 'Create your first project!'
          : isNew
              ? 'New project'
              : 'Update project',
      buttonTitle: first
          ? 'Let\'s started'
          : isNew
              ? 'Create'
              : 'Update',
      onValidate: onValidate,
      child: NewProjectPage(
        projectData: setupData,
        project: project,
      ),
    );
  }
}

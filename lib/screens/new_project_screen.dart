import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/pocketbase/provider.dart';
import 'package:shared/model/connectors/provider.dart';
import 'package:shared/model/instance.dart';
import 'package:shared/model/project_data.dart';
import 'package:shared/screens/new_screen.dart';

import '../components/pages/new_project/new_project_page.dart';
import '../model/app_data.dart';
import '../model/project.dart';
import 'main_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    setupData.instance = instance;
    bool newProject = project == null;

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
      onValidate: (context, formKey) async {
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
            await project!.provider.connect();
            AppData.current = project;
            await project!.conn.save();
            if (setupData.join) {
              await project!.provider.joinWithTitle();
            }
            await project!.sync();
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
                Navigator.pop(context, true);
              }
            }
          }
        }
      },
    );
  }
}

String getRandom(int length) {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  Random r = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => ch.codeUnitAt(
        r.nextInt(ch.length),
      ),
    ),
  );
}

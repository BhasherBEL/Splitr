import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/provider.dart';
import 'package:shared/model/project_data.dart';
import 'package:shared/screens/new_screen.dart';

import '../components/pages/new_project_page.dart';
import '../model/app_data.dart';
import '../model/project.dart';
import 'main_screen.dart';

class NewProjectScreen extends StatelessWidget {
  NewProjectScreen({this.first = false, this.project, super.key});

  final bool first;
  Project? project;

  ProjectData setupData = ProjectData();

  @override
  Widget build(BuildContext context) {
    return NewScreen(
      title: first
          ? 'Create your first project!'
          : project == null
              ? 'New project'
              : 'Update project',
      buttonTitle: first
          ? 'Let\'s started'
          : project == null
              ? 'Create'
              : 'Update',
      page: NewProjectPage(
        projectData: setupData,
        project: project,
      ),
      onValidate: (context, formKey) async {
        if (formKey.currentState != null && formKey.currentState!.validate()) {
          if (project == null) {
            project = Project(
              name: setupData.projectName!,
              code: setupData.join ? null : getRandom(5),
              providerId: setupData.providerId!,
              providerData: setupData.getProviderData(),
            );
          } else {
            project!.name = setupData.projectName!;
            project!.provider = Provider.initFromId(
              setupData.providerId!,
              project!,
              setupData.getProviderData(),
            );
          }
          try {
            await project!.provider.connect();
          } on ClientException {
            print('Connection error');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Connection error"),
                ),
              );
            }
            return;
          } catch (e) {
            print(e);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                ),
              );
            }
            return;
          }
          AppData.current = project;
          await project!.conn.save();
          if (setupData.join) {
            await project!.provider.joinWithTitle();
          }
          try {
            await project!.sync();
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
              Navigator.pop(context, true);
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

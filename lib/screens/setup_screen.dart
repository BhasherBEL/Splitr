import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/setup_data.dart';

import '../components/setup/project_setup_page.dart';
import '../model/app_data.dart';
import '../model/project.dart';
import 'main_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SetupScreen();
  }
}

class _SetupScreen extends StatefulWidget {
  const _SetupScreen({super.key});

  @override
  State<_SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<_SetupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();
  SetupData setupData = SetupData();

  String? error;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Create your first project!',
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Create your first project!"),
            elevation: 4,
          ),
          body: Form(
            key: formKey,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: [
                    if (error != null)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Card(
                          color: Colors.red,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              error!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 12, // <-- SEE HERE
                    ),
                    Expanded(
                      child: ProjectSetupPage(setupData),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState != null &&
                                    formKey.currentState!.validate()) {
// AppData.current
                                  Project project = Project(
                                    name: setupData.projectName!,
                                    providerId: setupData.providerId,
                                    providerData: setupData.providerData,
                                  );
                                  try {
                                    await project.provider.connect();
                                  } on ClientException {
                                    setState(() {
                                      error = 'Connection error';
                                    });
                                    return;
                                  } catch (e) {
                                    setState(() {
                                      error = e.toString();
                                    });
                                    return;
                                  }
                                  AppData.firstRun = false;
                                  runApp(const MainScreen());
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text("Let's started!"),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

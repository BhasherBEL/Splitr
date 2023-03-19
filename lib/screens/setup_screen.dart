import 'package:flutter/material.dart';
import 'package:shared/components/setup/user_setup_page.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';
import 'package:shared/model/setup_data.dart';

import '../components/setup/project_setup_page.dart';
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

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      UserSetupPage(setupData),
      ProjectSetupPage(setupData),
    ];
    return MaterialApp(
      title: 'Setup',
      theme: mainThemeData,
      home: Scaffold(
        body: Form(
          key: formKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: pages[currentPage],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: currentPage > 0
                                  ? ButtonStyle()
                                  : ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.grey.shade700),
                                    ),
                              onPressed: currentPage > 0
                                  ? () {
                                      setState(() {
                                        currentPage--;
                                      });
                                    }
                                  : null,
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text("Previous"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState != null &&
                                    formKey.currentState!.validate()) {
                                  if (currentPage == pages.length - 1) {
                                    AppData.current = Project(
                                      name: setupData.projectName!,
                                      providerId: setupData.providerId!,
                                      providerData: setupData.providerData,
                                    );
                                    AppData.me = Participant(
                                      pseudo: setupData.pseudo!,
                                      lastname: setupData.lastname,
                                      firstname: setupData.firstname,
                                    );
                                    AppData.current!.addParticipant(AppData.me);

                                    await AppData.current!.conn.save();
                                    await AppData.me.conn.save();
                                    await AppData.current!.conn
                                        .saveParticipants();
                                    AppData.firstRun = false;
                                    runApp(const MainScreen());
                                  } else {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(currentPage == pages.length - 1
                                    ? "Finish"
                                    : "Next"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

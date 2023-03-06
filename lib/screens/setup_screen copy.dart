import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:shared/components/setup/user_setup_page.dart';
import 'package:shared/model/setup_data.dart';

import '../components/setup/project_setup_page.dart';
import 'main_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Setup',
      theme: mainThemeData,
      home: Scaffold(
        body: FlowBuilder(
          state: const SetupData(),
          onGeneratePages: (state, pages) => [
            const MaterialPage(child: _SetupScreen(UserSetupPage())),
            if (state.pseudo != null)
              const MaterialPage(child: _SetupScreen(ProjectSetupPage())),
          ],
        ),
      ),
    );
  }
}

class _SetupScreen extends StatefulWidget {
  const _SetupScreen(this.page, {super.key});

  final Widget page;

  @override
  State<_SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<_SetupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
                    child: widget.page,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.grey.shade700),
                              ),
                              onPressed: currentPage > 0
                                  ? () {
                                      if (formKey.currentState != null &&
                                          formKey.currentState!.validate()) {
                                        setState(() {
                                          currentPage--;
                                        });
                                      }
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
                              onPressed: () {
                                if (formKey.currentState != null &&
                                    formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  setState(() {
                                    context.flow<SetupData>().update((state) => state.copyWith(pseudo: formKey.currentState.))
                                  });
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text("Next"),
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

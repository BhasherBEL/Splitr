import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class NewScreen extends StatelessWidget {
  NewScreen({
    super.key,
    this.title,
    required this.page,
    this.onValidate,
    this.buttonTitle,
  });

  String? title;
  Widget page;
  void Function(BuildContext context, GlobalKey<FormState> formKey)? onValidate;
  final GlobalKey<FormState> formKey = GlobalKey();
  String? buttonTitle;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: title ?? 'Shared',
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        home: Scaffold(
          appBar: title == null
              ? null
              : AppBar(
                  title: Text(title!),
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
                    Expanded(
                      child: page,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onValidate == null
                              ? null
                              : () => onValidate!(context, formKey),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                                buttonTitle == null ? "Finish" : buttonTitle!),
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

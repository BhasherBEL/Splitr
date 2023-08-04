import 'package:flutter/material.dart';

class NewScreen extends StatelessWidget {
  NewScreen({
    super.key,
    this.title,
    required this.child,
    this.onValidate,
    this.buttonTitle,
  });

  final String? title;
  final Widget child;
  final Future Function(BuildContext context, GlobalKey<FormState> formKey)?
      onValidate;
  final GlobalKey<FormState> formKey = GlobalKey();
  final String? buttonTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(
                title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body: Builder(
        builder: (context) => Form(
          key: formKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  Expanded(
                    child: child,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onValidate == null
                            ? () async =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please check your entries'),
                                  ),
                                )
                            : () async => await onValidate!(context, formKey),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                              buttonTitle == null ? 'Finish' : buttonTitle!),
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
  }
}

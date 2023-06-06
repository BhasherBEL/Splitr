import 'package:flutter/material.dart';

class TextSwitch extends StatelessWidget {
  const TextSwitch({
    super.key,
    required this.state,
    this.leftText = '',
    this.rightText = '',
    this.onChanged,
    this.padding = 10,
  });

  final bool state;
  final String leftText;
  final String rightText;
  final Function(bool newState)? onChanged;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(leftText),
        SizedBox(
          width: padding,
        ),
        Switch(
          value: state,
          onChanged: onChanged,
        ),
        SizedBox(
          width: padding,
        ),
        Text(rightText),
      ],
    );
  }
}

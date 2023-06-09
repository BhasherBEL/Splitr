import 'dart:math';

import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter(this.decimalRange) : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    // try {
    //   return TextEditingValue(
    //     text: double.parse(newValue.text).toStringAsPrecision(2),
    //     selection: newSelection,
    //     composing: TextRange.empty,
    //   );
    // } catch (e) {
    //   return TextEditingValue(
    //     text: oldValue.text,
    //     selection: oldValue.selection,
    //     composing: oldValue.composing,
    //   );
    // }

    if (truncated == ".") {
      truncated = '0.';
      newSelection = newValue.selection.copyWith(
        baseOffset: min(truncated.length, truncated.length + 1),
        extentOffset: min(truncated.length, truncated.length + 1),
      );
    }

    if (truncated.isEmpty ||
        RegExp(r'^[0-9]*(\.[0-9]{0,2})?$').hasMatch(truncated)) {
      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    } else {
      return TextEditingValue(
        text: oldValue.text,
        selection: oldValue.selection,
        composing: oldValue.composing,
      );
    }
  }
}

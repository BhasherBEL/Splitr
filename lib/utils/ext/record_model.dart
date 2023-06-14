import 'package:pocketbase/pocketbase.dart';

extension RecordModelExtension on RecordModel {
  double? getDoubleOrNullValue(String fieldName) {
    return getStringValue(fieldName).isEmpty ? null : getDoubleValue(fieldName);
  }
}

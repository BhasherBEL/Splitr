import 'package:pocketbase/pocketbase.dart';

extension RecordModelExtension on RecordModel {
  double? getDoubleOrNullValue(String fieldName) {
    return getStringValue(fieldName).isEmpty ? null : getDoubleValue(fieldName);
  }
}

extension RecordServiceExtension on RecordService {
  Future<RecordModel> updateOrCreate({
    String? id,
    required Map<String, dynamic> body,
  }) {
    if (id == null) {
      return create(body: body);
    } else {
      return update(id, body: body);
    }
  }
}

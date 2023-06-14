import '../../models/data.dart';

extension DataSetExtension<E extends Data> on Set<E> {
  Iterable<E> enabled() {
    return where((element) => !element.deleted);
  }
}

import '../../models/data.dart';

extension ListExtension<E> on List<E> {
  void setPresence(bool presence, E element) {
    if (presence) {
      if (!contains(element)) {
        add(element);
      }
    } else {
      remove(element);
    }
  }
}

extension DataListExtension<E extends Data> on List<E> {
  Iterable<E> enabled() {
    return where((element) => !element.deleted);
  }
}

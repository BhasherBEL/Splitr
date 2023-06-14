
extension DateTimeExtension on DateTime {
  bool operator <(DateTime other) {
    return millisecondsSinceEpoch < other.millisecondsSinceEpoch;
  }

  bool operator <=(DateTime other) {
    return millisecondsSinceEpoch <= other.millisecondsSinceEpoch;
  }

  bool operator >(DateTime other) {
    return millisecondsSinceEpoch > other.millisecondsSinceEpoch;
  }

  bool operator >=(DateTime other) {
    return millisecondsSinceEpoch >= other.millisecondsSinceEpoch;
  }
}

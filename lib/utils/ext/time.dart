import 'package:intl/intl.dart';

String monthText(int month) {
  return [
    '',
    'January',
    'Febuary',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'november',
    'december'
  ][month];
}

extension DateExtension on DateTime {
  static DateTime now = DateTime.now();
  String toDate() {
    if (year != now.year) {
      return '$day${day == 1 ? 'st' : 'th'} ${monthText(month)} $year';
    } else {
      return '$day${day == 1 ? 'st' : 'th'} ${monthText(month)}';
    }
  }

  String toPocketTime() {
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(this);
  }

  String getFullDate() {
    return "${day.toString().padLeft(2, '0')} ${monthText(month)} ${year.toString().padLeft(4, '0')}";
  }

  DateTime getDay() {
    return DateTime(year, month, day);
  }

  String daysElapsed() {
    DateTime now = DateTime.now();

    int delta = daysTo(now);
    if (delta == 0) return 'today';
    if (delta == 1) return 'yesterday';
    if (delta == -1) return 'tomorrow';
    if (delta > -7 && delta < -1) return 'in ${-delta} days';
    if (delta < 7) return '$delta days ago';

    if (year != now.year) {
      return '$day${day == 1 ? 'st' : 'th'} ${monthText(month)} $year';
    } else {
      return '$day${day == 1 ? 'st' : 'th'} ${monthText(month)}';
    }
  }

// https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates
  int daysSince(DateTime from) {
    from = DateTime(from.year, from.month, from.day);
    DateTime to = DateTime(year, month, day);
    return (to.difference(from).inHours / 24).round();
  }

  int daysTo(DateTime to) {
    DateTime from = DateTime(year, month, day);
    to = DateTime(from.year, from.month, from.day);
    return (to.difference(from).inHours / 24).round();
  }

  String timeElapsed() {
    DateTime now = DateTime.now();

    Duration difference = now.difference(this);

    if (difference.inDays > 7) {
      if (year < now.year) {
        return '$day${day == 1 ? 'st' : 'th'} ${monthText(month)} $year';
      } else {
        return '$day${day == 1 ? 'st' : 'th'} ${monthText(month)}';
      }
    } else if (difference.inDays > 0) {
      return _plural('day', difference.inDays);
    } else if (difference.inHours > 0) {
      return _plural('hour', difference.inHours);
    } else if (difference.inMinutes > 0) {
      return _plural('minute', difference.inMinutes);
    } else {
      return _plural('second', difference.inSeconds);
    }
  }
}

String _plural(String word, int amount) {
  return '$amount $word${amount != 1 ? 's' : ''} ago';
}

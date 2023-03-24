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

String getFullDate(DateTime dateTime) {
  return "${dateTime.day.toString().padLeft(2, '0')} ${monthText(dateTime.month)} ${dateTime.year.toString().padLeft(4, '0')}";
}

DateTime getDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

String daysElapsed(DateTime dateTime) {
  DateTime now = DateTime.now();

  int delta = daysBetween(dateTime, now);
  if (delta == 0) return 'today';
  if (delta == 1) return 'yesterday';
  if (delta == -1) return 'tomorrow';
  if (delta > -7 && delta < -1) return 'in ${-delta} days';
  if (delta < 7) return '$delta days ago';

  if (dateTime.year != now.year) {
    return '${dateTime.day}${dateTime.day == 1 ? 'st' : 'th'} ${monthText(dateTime.month)} ${dateTime.year}';
  } else {
    return '${dateTime.day}${dateTime.day == 1 ? 'st' : 'th'} ${monthText(dateTime.month)}';
  }
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
}

DateTime fromPocketTime(String s) {
  // return DateFormat("yyyy-MM-dd hh:mm:ss").parse(s, true);
  return DateTime.parse(s);
}

// https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String _plural(String word, int amount) {
  return '$amount $word${amount != 1 ? 's' : ''} ago';
}

String timeElapsed(DateTime dateTime) {
  DateTime now = DateTime.now();

  Duration difference = now.difference(dateTime);

  if (difference.inDays > 7) {
    if (dateTime.year < now.year) {
      return '${dateTime.day}${dateTime.day == 1 ? 'st' : 'th'} ${monthText(dateTime.month)} ${dateTime.year}';
    } else {
      return '${dateTime.day}${dateTime.day == 1 ? 'st' : 'th'} ${monthText(dateTime.month)}';
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

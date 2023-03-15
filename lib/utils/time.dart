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

String daysElapsed(DateTime dateTime) {
  DateTime now = DateTime.now();

  if (now.year == dateTime.year && now.month == dateTime.month) {
    if (now.day == dateTime.day) return 'today';
    if (now.day == dateTime.day + 1) return 'yesterday';
  }

  int delta = daysBetween(dateTime, now);
  if (delta < 7) return delta.toString() + ' days ago';

  return timeElapsed(dateTime);
}

String getStringDate(DateTime dateTime) {
  return dateTime.year.toString().padLeft(4, '0') +
      dateTime.month.toString().padLeft(2, '0') +
      dateTime.day.toString().padLeft(2, '0');
}

// https://stackoverflow.com/questions/52713115/flutter-find-the-number-of-days-between-two-dates
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

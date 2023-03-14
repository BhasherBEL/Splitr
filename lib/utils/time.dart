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

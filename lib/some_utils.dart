class SomeUtils {
  static DateTime getStartDateDefault() {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime getLastDateDefault() {
    var now = DateTime.now().add(Duration(days: 60));
    return DateTime(now.year, now.month);
  }

  static DateTime setToMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int getCountFromDiffDate(DateTime firstDate, DateTime lastDate) {
    var yearsDifference = lastDate.year - firstDate.year;
    return 12 * yearsDifference + lastDate.month - firstDate.month;
  }

  static int getDiffMonth(DateTime startDate, DateTime date) {
    return (date.year * 12 + date.month) -
        (startDate.year * 12 + startDate.month);
  }
}

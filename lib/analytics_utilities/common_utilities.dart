import 'package:flutter/material.dart';

DateTime startOfDay(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}

Set<DateTime> daysFromRange(DateTimeRange range) {
  int totalDays = range.duration.inDays + 1;
  Set<DateTime> days = {};
  DateTime firstDay = startOfDay(range.start);
  for (int i = 0; i < totalDays; i++) {
    days.add(firstDay.add(Duration(days: i)));
  }
  return days;
}

DateTime oldestDate(List<DateTime> dates) {
  return dates.reduce((min, date) => date.isBefore(min) ? date : min);
}

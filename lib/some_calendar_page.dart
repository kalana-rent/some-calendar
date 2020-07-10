import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar.dart';
import 'package:some_calendar/some_week_label.dart';

class SomeCalendarPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime lastDate;
  final OnTapFunction onTapFunction;
  final Function onTapDayOfWeek;
  final SomeCalendarState state;
  final SomeMode mode;
  final Color primaryColor;
  final Color textColor;
  final Color blackoutColor;

  SomeCalendarPage({
    Key key,
    @required this.startDate,
    @required this.lastDate,
    this.onTapFunction,
    this.onTapDayOfWeek,
    this.state,
    this.mode,
    this.primaryColor,
    this.textColor,
    this.blackoutColor,
  });

  @override
  _SomeCalendarPageState createState() => _SomeCalendarPageState(
        startDate: startDate,
        lastDate: lastDate,
        onTapFunction: onTapFunction,
        onTapDayOfWeek: onTapDayOfWeek,
        state: state,
        mode: mode,
        primaryColor: primaryColor,
        textColor: textColor,
        blackoutColor: blackoutColor,
      );
}

class _SomeCalendarPageState extends State<SomeCalendarPage> {
  final DateTime startDate;
  final DateTime lastDate;
  final OnTapFunction onTapFunction;
  final Function onTapDayOfWeek;
  final SomeCalendarState state;
  final SomeMode mode;
  final Color primaryColor;
  final Color textColor;
  final Color blackoutColor;

  int startDayOffset = 0;
  List<DateTime> selectedDates;
  List<DateTime> blackoutDates;
  DateTime selectedDate;
  List<int> blackoutDays;
  List<int> blackoutMonths;

  _SomeCalendarPageState({
    this.startDate,
    this.lastDate,
    this.onTapFunction,
    this.onTapDayOfWeek,
    this.state,
    this.mode,
    this.primaryColor,
    this.textColor,
    this.blackoutColor,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (mode == SomeMode.Multi || mode == SomeMode.Range) {
      selectedDates = state.selectedDates;
      blackoutDates = state.blackoutDates;
      blackoutDays = state.blackoutDays;
      blackoutMonths = state.blackoutMonths;
    } else if (mode == SomeMode.Single) {
      selectedDate = state.selectedDate;
      blackoutDays = state.blackoutDays;
      blackoutMonths = state.blackoutMonths;
    }
    List<Widget> rows = [];
    rows.add(
      SomeWeekLabel(
        onTapDayOfWeek: onTapDayOfWeek,
        textColor: textColor,
        blackoutColor: blackoutColor,
        primaryColor: primaryColor,
        blackoutDays: blackoutDays,
      ),
    );

    var dateTime = Jiffy(startDate);
    for (int i = 1; i < 7; i++) {
      if (lastDate.isAfter(dateTime.dateTime)) {
        rows.add(Row(
          children: buildSomeCalendarDay(dateTime.dateTime, lastDate, i),
        ));
        var tempTime = dateTime;
        dateTime = dateTime..add(days: startDayOffset);
        if (dateTime.dateTime.day == tempTime.dateTime.day &&
            dateTime.dateTime.hour == 23) {
          dateTime = dateTime..add(hours: 1);
        }
      } else {
        rows.add(Row(
            children: buildSomeCalendarDay(dateTime.dateTime, lastDate, i)));
        dateTime = dateTime..add(days: startDayOffset);
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  List<Widget> buildSomeCalendarDay(
      DateTime rowStartDate, DateTime rowEndDate, int position) {
    List<Widget> items = [];
    DateTime currentDate = rowStartDate;
    rowEndDate = Jiffy(rowEndDate).add(days: 1);
    startDayOffset = 0;
    if (position == 1) {
      for (int i = 0; i < 7; i++) {
        if (i + 1 == rowStartDate.weekday + 1) {
          items.add(someDay(currentDate));
          startDayOffset++;
          currentDate = currentDate.add(Duration(days: 1));
        } else if (i + 1 > rowStartDate.weekday) {
          if (rowEndDate.isAfter(currentDate)) {
            items.add(someDay(currentDate));
            startDayOffset++;
            currentDate = currentDate.add(Duration(days: 1));
          } else {
            items.add(someDayEmpty());
          }
        } else {
          items.add(someDayEmpty());
        }
      }
    } else {
      for (int i = 0; i < 7; i++) {
        if (rowEndDate.isAfter(currentDate)) {
          items.add(someDay(currentDate));
          startDayOffset++;
          currentDate = currentDate.add(Duration(days: 1));
        } else {
          items.add(someDayEmpty());
        }
      }
    }
    return items;
  }

  Widget someDay(currentDate) {
    return Expanded(
      child: Container(
        decoration: getDecoration(currentDate),
        margin: EdgeInsets.only(top: 2, bottom: 2),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: InkWell(
            onTap: blackoutDates != null &&
                        blackoutDates.isNotEmpty &&
                        blackoutDates.contains(currentDate) ||
                    blackoutDays != null &&
                        blackoutDays.isNotEmpty &&
                        isBlackoutDay(currentDate) ||
                    blackoutMonths != null &&
                        blackoutMonths.isNotEmpty &&
                        isBlackoutMonth(currentDate)
                ? null // TODO: create call back to alert the user they selected a date that is unavailable
                : () {
                    setState(() {
                      onTapFunction(currentDate);
                    });
                  },
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Center(
                  child: Text(
                    "${currentDate.day}",
                    style: TextStyle(color: getColor(currentDate)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget someDayEmpty() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text("")),
      ),
    );
  }

  Color getColor(currentDate) {
    if (mode == SomeMode.Multi || mode == SomeMode.Range) {
      if (selectedDates.contains(currentDate)) {
        return Colors.white;
      } else if (blackoutDates.contains(currentDate) ||
          isBlackoutDay(currentDate) ||
          isBlackoutMonth(currentDate)) {
        return blackoutColor != null ? blackoutColor : Colors.grey;
      } else {
        return textColor;
      }
    } else if (mode == SomeMode.Single) {
      return selectedDate == currentDate
          ? Colors.white
          : (isWeekend(currentDate) ? textColor.withAlpha(222) : textColor);
    } else {
      return null;
    }
  }

  bool isWeekend(currentDate) {
    return currentDate.weekday == DateTime.sunday ||
        currentDate.weekday == DateTime.saturday;
  }

  bool isBlackoutDay(currentDate) {
    if (blackoutDays != null) if (blackoutDays.isNotEmpty)
      return blackoutDays.contains(currentDate.weekday);

    return false;
  }

  bool isBlackoutMonth(currentDate) {
    if (blackoutMonths != null) if (blackoutMonths.isNotEmpty)
      return blackoutMonths.contains(currentDate.month);
    return false;
  }

  Decoration getDecoration(currentDate) {
    var decoration = BoxDecoration(
      color: primaryColor,
      shape: BoxShape.circle,
    );
    if (mode == SomeMode.Multi) {
      return selectedDates.contains(currentDate) ? decoration : null;
    } else if (mode == SomeMode.Single) {
      return selectedDate == currentDate ? decoration : null;
    } else if (selectedDates != null && selectedDates.length > 0) {
      if (selectedDates[0] == currentDate) {
        if (selectedDates.length == 1) {
          return BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
          );
        } else {
          return BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              topLeft: Radius.circular(50),
            ),
          );
        }
      } else if (selectedDates[selectedDates.length - 1] == currentDate) {
        return BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        );
      } else {
        if (selectedDates.contains(currentDate)) {
          return BoxDecoration(
            color: primaryColor.withAlpha(180),
            shape: BoxShape.rectangle,
          );
        } else {
          return null;
        }
      }
    } else {
      return null;
    }
  }
}

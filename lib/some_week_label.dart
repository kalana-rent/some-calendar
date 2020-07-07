import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SomeWeekLabel extends StatelessWidget {
  final Color textColor;
  final Color blackoutColor;
  final int firstDayOfWeek;
  final bool blackout;

  const SomeWeekLabel(
      {Key key,
      this.textColor,
      this.blackoutColor,
      this.firstDayOfWeek = 0,
      this.blackout = false})
      : super(key: key);

  Widget _weekdayContainer(String weekDayName, TextStyle textStyle) {
    return Expanded(
      child: Text(
        weekDayName.replaceAll('.', ''),
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontFamily: "playfair-regular",
      fontSize: 14.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      color: !blackout ? textColor : blackoutColor,
    );

    List<Widget> list = [];

    // based on https://github.com/dooboolab/flutter_calendar_carousel/blob/master/lib/src/weekday_row.dart

    DateFormat _localeDate = DateFormat.yMMM();
    for (var i = firstDayOfWeek, count = 0;
        count < 7;
        i = (i + 1) % 7, count++) {
      list.add(_weekdayContainer(
          _localeDate.dateSymbols.STANDALONESHORTWEEKDAYS[i], textStyle));
    }

    return Row(children: list);
  }
}

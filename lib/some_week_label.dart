import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SomeWeekLabel extends StatelessWidget {
  final Function? onTapDayOfWeek;
  final Color? textColor;
  final Color? blackoutColor;
  final Color? primaryColor;
  final int firstDayOfWeek;
  final List<int>? blackoutDays;
  final bool? isBlackout;

  const SomeWeekLabel({
    Key? key,
    this.onTapDayOfWeek,
    this.textColor,
    this.blackoutColor,
    this.primaryColor,
    this.firstDayOfWeek = 0,
    this.blackoutDays = const [],
    this.isBlackout = false,
  }) : super(key: key);

  Widget _weekdayContainer(
      String weekDayName, TextStyle textStyle, int dayOfWeek) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
        child: InkWell(
          onTap: isBlackout!
              ? () {
                  onTapDayOfWeek!(dayOfWeek);
                }
              : null,
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
          child: Container(
            decoration: getDecoration(dayOfWeek),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Text(
                weekDayName.replaceAll('.', ''),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Decoration getDecoration(int dayOfWeek) {
    if (isBlackout! && blackoutDays!.contains(dayOfWeek)) {
      return BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      );
    } else {
      return BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    // based on https://github.com/dooboolab/flutter_calendar_carousel/blob/master/lib/src/weekday_row.dart

    DateFormat _localeDate = DateFormat.yMMM();
    for (int i = firstDayOfWeek, count = 0;
        count < 7;
        i = (i + 1) % 7, count++) {
      TextStyle textStyle = TextStyle(
        fontFamily: "playfair-regular",
        fontSize: 14.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: !isBlackout! ? textColor : blackoutDays!.contains(i) ? Colors.white : textColor,
      );
      list.add(_weekdayContainer(
          _localeDate.dateSymbols.NARROWWEEKDAYS[i], textStyle, i));
    }

    return Row(children: list);
  }
}

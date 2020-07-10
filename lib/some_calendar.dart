library some_calendar;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar_page.dart';
import 'package:some_calendar/some_date_range.dart';
import 'package:some_calendar/some_utils.dart';

typedef void OnTapFunction(DateTime date);
typedef void OnDoneFunction(date);

enum SomeMode { Range, Single, Multi }

class Labels {
  final String dialogDone,
      dialogCancel,
      dialogRangeFirstDate,
      dialogRangeLastDate;

  Labels({
    this.dialogDone = 'Done',
    this.dialogCancel = 'Cancel',
    this.dialogRangeFirstDate = 'First Date',
    this.dialogRangeLastDate = 'Last Date',
  });
}

class SomeCalendar extends StatefulWidget {
  final SomeMode mode;
  final OnDoneFunction done;

  DateTime startDate;
  DateTime lastDate;
  DateTime selectedDate;
  List<DateTime> selectedDates;
  List<DateTime> blackoutDates;
  List<int> blackoutDays;
  List<int> blackoutMonths;
  final Axis scrollDirection;
  final Color primaryColor;
  final Color textColor;
  final Color blackoutColor;
  final bool isWithoutDialog;
  final bool isBlackout;

  final Labels labels;

  SomeCalendar({
    Key key,
    @required this.mode,
    this.startDate,
    this.lastDate,
    this.done,
    this.selectedDate,
    this.selectedDates, // Used for selection, of blackout dates and desired purchase dates
    this.blackoutDates, // Used as input only
    this.blackoutDays, // Days of the week to blackout
    this.blackoutMonths, // Months to blackout every year
    this.primaryColor,
    this.textColor,
    this.blackoutColor,
    this.isWithoutDialog,
    this.labels,
    this.scrollDirection,
    this.isBlackout = false,
  }) {
    DateTime now = Jiffy().dateTime;
    assert(mode != null);
    if (startDate == null) startDate = SomeUtils.getStartDateDefault();
    if (lastDate == null) lastDate = SomeUtils.getLastDateDefault();
    if (selectedDates == null) selectedDates = List();
    if (blackoutDates == null) blackoutDates = List();
    if (selectedDate == null) {
      selectedDate = Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
    }
  }

  @override
  SomeCalendarState createState() => SomeCalendarState(
        lastDate: lastDate,
        startDate: startDate,
        mode: mode,
        done: done,
        textColor: textColor,
        blackoutColor: blackoutColor,
        selectedDates: selectedDates,
        selectedDate: selectedDate,
        blackoutDates: blackoutDates,
        blackoutDays: blackoutDays,
        blackoutMonths: blackoutMonths,
        primaryColor: primaryColor,
        isWithoutDialog: isWithoutDialog,
        labels: labels,
        scrollDirection: scrollDirection,
        isBlackout: isBlackout,
      );

  static SomeCalendarState of(BuildContext context) =>
      context.findAncestorStateOfType();
}

class SomeCalendarState extends State<SomeCalendar> {
  final OnDoneFunction done;

  DateTime startDate;
  DateTime lastDate;
  SomeMode mode;

  PageView pageView;
  PageController controller;

  int pagesCount;
  String month;
  String year;

  String monthFirstDate;
  String yearFirstDate;
  String dateFirstDate;

  String monthEndDate;
  String yearEndDate;
  String dateEndDate;

  List<DateTime> selectedDates;
  DateTime selectedDate;
  DateTime firstRangeDate;
  DateTime endRangeDate;
  List<DateTime> blackoutDates;
  List<int> blackoutDays;
  List<int> blackoutMonths;

  DateTime now;
  bool isSelectedModeFirstDateRange;
  Color primaryColor;
  Color textColor;
  Color blackoutColor;
  bool isWithoutDialog;
  Axis scrollDirection;
  bool isBlackout;

  Labels labels;

  SomeDateRange someDateRange;

  SomeCalendarState({
    @required this.done,
    this.startDate,
    this.lastDate,
    this.selectedDate,
    this.selectedDates,
    this.blackoutDates,
    this.blackoutDays,
    this.blackoutMonths,
    this.mode,
    this.primaryColor,
    this.textColor,
    this.blackoutColor,
    this.isWithoutDialog,
    this.labels,
    this.scrollDirection,
    this.isBlackout,
  }) {
    now = Jiffy().dateTime;
    if (scrollDirection == null) scrollDirection = Axis.vertical;
    if (isWithoutDialog == null) isWithoutDialog = true;
    if (labels == null) labels = new Labels();
    if (mode == SomeMode.Multi || mode == SomeMode.Range) {
      if (selectedDates.length > 0) {
        List<DateTime> tempListDates = List();
        for (var value in selectedDates) {
          tempListDates.add(SomeUtils.setToMidnight(value));
        }
        selectedDates.clear();
        selectedDates.addAll(tempListDates);
      }
      if (blackoutDates.length > 0) {
        List<DateTime> tempListDates = List();
        for (var value in blackoutDates) {
          tempListDates.add(SomeUtils.setToMidnight(value));
        }
        blackoutDates.clear();
        blackoutDates.addAll(tempListDates);
      }
    } else {
      selectedDate = SomeUtils.setToMidnight(selectedDate);
    }

    if (blackoutDates.length > 0) {
      List<DateTime> tempListDates = List();
      for (var value in blackoutDates) {
        tempListDates.add(SomeUtils.setToMidnight(value));
      }
      blackoutDates.clear();
      blackoutDates.addAll(tempListDates);
    }

    // } else {
    //   blackoutDate = SomeUtils.setToMidnight(blackoutDate);
    // }

    if (textColor == null) textColor = Colors.black;
    if (blackoutColor == null) blackoutColor = Colors.grey;
    if (primaryColor == null) primaryColor = Color(0xff365535);
    if (mode == SomeMode.Range) {
      if (selectedDates == null) {
        firstRangeDate = Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
        endRangeDate =
            Jiffy(DateTime(now.year, now.month, now.day)).add(days: 2);
      } else {
        DateTime dateRange = now;
        if (selectedDates.length > 0) {
          dateRange = selectedDates[0];
        }
        if (dateRange.difference(startDate).inDays >= 0) {
          if (selectedDates.length > 0) {
            firstRangeDate = Jiffy(selectedDates[0]).dateTime;
            endRangeDate =
                Jiffy(selectedDates[selectedDates.length - 1]).dateTime;
          } else {
            firstRangeDate =
                Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
            endRangeDate =
                Jiffy(DateTime(now.year, now.month, now.day)).add(days: 2);
          }
        } else {
          firstRangeDate =
              Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
          endRangeDate =
              Jiffy(DateTime(now.year, now.month, now.day)).add(days: 2);
        }
      }

      if (blackoutDates == null) {
        firstRangeDate = Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
        endRangeDate =
            Jiffy(DateTime(now.year, now.month, now.day)).add(days: 2);
      } else {
        DateTime dateRange = now;
        if (blackoutDates.length > 0) {
          dateRange = blackoutDates[0];
        }
        if (dateRange.difference(startDate).inDays >= 0) {
          if (blackoutDates.length > 0) {
            firstRangeDate = Jiffy(blackoutDates[0]).dateTime;
            endRangeDate =
                Jiffy(blackoutDates[blackoutDates.length - 1]).dateTime;
          } else {
            firstRangeDate =
                Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
            endRangeDate =
                Jiffy(DateTime(now.year, now.month, now.day)).add(days: 2);
          }
        } else {
          firstRangeDate =
              Jiffy(DateTime(now.year, now.month, now.day)).dateTime;
          endRangeDate =
              Jiffy(DateTime(now.year, now.month, now.day)).add(days: 2);
        }
      }

      isSelectedModeFirstDateRange = true;
      dateFirstDate = Jiffy(firstRangeDate).format("dd");
      monthFirstDate = Jiffy(firstRangeDate).format("MMM");
      yearFirstDate = Jiffy(firstRangeDate).format("yyyy");

      dateEndDate = Jiffy(endRangeDate).format("dd");
      monthEndDate = Jiffy(endRangeDate).format("MMM");
      yearEndDate = Jiffy(endRangeDate).format("yyyy");
      if (selectedDates.length <= 0)
        generateListDateRange();
      else {
        var diff = selectedDates[selectedDates.length - 1]
                .difference(selectedDates[0])
                .inDays +
            1;
        var date = selectedDates[0];
        selectedDates.clear();
        for (int i = 0; i < diff; i++) {
          selectedDates.add(date);
          date = Jiffy(date).add(days: 1);
        }
      }
    } else {
      dateFirstDate = Jiffy(selectedDate).format("dd");
      monthFirstDate = Jiffy(selectedDate).format("MMM");
      yearFirstDate = Jiffy(selectedDate).format("yyyy");
    }
  }

  @override
  void initState() {
    month = monthFirstDate;
    year = yearFirstDate;
    startDate = SomeUtils.setToMidnight(startDate);
    lastDate = SomeUtils.setToMidnight(lastDate);
    pagesCount = SomeUtils.getCountFromDiffDate(startDate, lastDate);
    controller =
        PageController(keepPage: false, initialPage: getInitialController());
    rebuildPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isWithoutDialog)
      return withoutDialog();
    else
    return withoutDialog();
      // return show();
  }

  void rebuildPage() {
    pageView = PageView.builder(
      controller: controller,
      scrollDirection: scrollDirection,
      itemCount: pagesCount,
      onPageChanged: (index) {
        someDateRange = getDateRange(index);
        setState(() {
          someDateRange = someDateRange;
          if (mode == SomeMode.Multi) {
            monthFirstDate = Jiffy(someDateRange.startDate).format("MMM");
            yearFirstDate = Jiffy(someDateRange.startDate).format("yyyy");
            month = Jiffy(someDateRange.startDate).format("MMM");
            year = Jiffy(someDateRange.startDate).format("yyyy");
          } else if (mode == SomeMode.Range || mode == SomeMode.Single) {
            month = Jiffy(someDateRange.startDate).format("MMM");
            year = Jiffy(someDateRange.startDate).format("yyyy");
          }
        });
      },
      itemBuilder: (context, index) {
        SomeDateRange someDateRange = getDateRange(index);
        return Container(
            child: SomeCalendarPage(
          startDate: someDateRange.startDate,
          lastDate: someDateRange.endDate,
          onTapFunction: onCallback,
          onTapDayOfWeek: dayOfWeekCallback,
          state: SomeCalendar.of(context),
          mode: mode,
          primaryColor: primaryColor,
          textColor: textColor,
          blackoutColor: blackoutColor,
        ));
      },
    );
  }

  int getInitialController() {
    if (selectedDate == null) {
      return SomeUtils.getDiffMonth(startDate, Jiffy().dateTime);
    } else {
      if (selectedDate.difference(startDate).inDays >= 0)
        return SomeUtils.getDiffMonth(startDate, selectedDate);
      else
        return SomeUtils.getDiffMonth(startDate, Jiffy().dateTime);
    }
  }

  void onCallback(DateTime a) {
    if (mode == SomeMode.Multi) {
      if (selectedDates.contains(a))
        selectedDates.remove(a);
      else
        selectedDates.add(a);
      selectedDates.sort((a, b) {
        return a.compareTo(b);
      });
      if (isWithoutDialog) {
        done(selectedDates);
      }
    } else if (mode == SomeMode.Single) {
      selectedDate = a;
      setState(() {
        dateFirstDate = Jiffy(selectedDate).format("dd");
        monthFirstDate = Jiffy(selectedDate).format("MMM");
        yearFirstDate = Jiffy(selectedDate).format("yyyy");
        if (isWithoutDialog) {
          done(selectedDate);
        }
      });
    } else {
      if (isSelectedModeFirstDateRange) {
        if (a.isBefore(endRangeDate)) {
          firstRangeDate = a;
        } else {
          endRangeDate = a;
        }
      } else {
        if (a.isBefore(firstRangeDate)) {
          firstRangeDate = a;
        } else {
          endRangeDate = a;
        }
      }

      selectedDates.clear();
      generateListDateRange();
      selectedDates.sort((a, b) => a.compareTo(b));
      setState(() {
        dateFirstDate = Jiffy(firstRangeDate).format("dd");
        monthFirstDate = Jiffy(firstRangeDate).format("MMM");
        yearFirstDate = Jiffy(firstRangeDate).format("yyyy");
        dateEndDate = Jiffy(endRangeDate).format("dd");
        monthEndDate = Jiffy(endRangeDate).format("MMM");
        yearEndDate = Jiffy(endRangeDate).format("yyyy");
      });

      if (isWithoutDialog) {
        if (widget.isBlackout) blackoutDates = selectedDates;
        done(!widget.isBlackout ? selectedDates : blackoutDates);
      }
    }
  }

  void dayOfWeekCallback(int dayOfWeek) {
    if (blackoutDays.contains(dayOfWeek)) {
      setState(() {
        blackoutDays.remove(dayOfWeek);
      });
    } else {
      setState(() {
        blackoutDays.add(dayOfWeek);
      });
    }
    rebuildPage();
  }

  void monthCallback(DateTime startDateOfMonth) {
    int month = startDateOfMonth.month;
    if (blackoutMonths.contains(month)) {
      setState(() {
        blackoutMonths.remove(month);
      });
    } else {
      setState(() {
        blackoutMonths.add(month);
      });
    }
    rebuildPage();
  }

  void generateListDateRange() {
    var diff = endRangeDate.difference(firstRangeDate).inDays + 1;
    var date = firstRangeDate;
    for (int i = 0; i < diff; i++) {
      selectedDates.add(date);
      date = Jiffy(date).add(days: 1);
    }
  }

  SomeDateRange getDateRange(int position) {
    DateTime pageStartDate;
    DateTime pageEndDate;

    if (position == 0) {
      pageStartDate = startDate;
      if (pagesCount <= 1) {
        pageEndDate = lastDate;
      } else {
        var last = Jiffy(DateTime(startDate.year, startDate.month))
          ..add(months: 1);
        var lastDayOfMonth = last..subtract(days: 1);
        pageEndDate = lastDayOfMonth.dateTime;
      }
    } else if (position == pagesCount - 1) {
      var start = Jiffy(DateTime(lastDate.year, lastDate.month))
        ..subtract(months: 1);
      pageStartDate = start.dateTime;
      pageEndDate = Jiffy(lastDate).subtract(days: 1);
    } else {
      var firstDateOfCurrentMonth =
          Jiffy(DateTime(startDate.year, startDate.month))
            ..add(months: position);
      pageStartDate = firstDateOfCurrentMonth.dateTime;
      var a = firstDateOfCurrentMonth
        ..add(months: 1)
        ..subtract(days: 1);
      pageEndDate = a.dateTime;
    }
    return SomeDateRange(pageStartDate, pageEndDate);
  }

  withoutDialog() {
    var heightContainer = mode == SomeMode.Range ? 55 * 6 : 55 * 6;
    return Container(
      height: heightContainer.toDouble(),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => {
                  monthCallback(
                      someDateRange == null ? now : someDateRange.startDate),
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontFamily: "playfair-regular",
                          fontSize: 14.2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: textColor),
                      children: <TextSpan>[
                        TextSpan(
                          text: '$month',
                        ),
                        TextSpan(
                          text: ', ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,8,8,8),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontFamily: "playfair-regular",
                        fontSize: 14.2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: textColor),
                    children: <TextSpan>[
                      TextSpan(
                        text: '$year',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(height: heightContainer.toDouble(), child: pageView),
              ],
            ),
          ),
        ],
      ),
    );
  }

  show() {
    var heightContainer = mode == SomeMode.Range ? 55 * 6 : 55 * 6;
    return AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(0, 16, 0, 5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      title: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (mode == SomeMode.Range) ...[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isSelectedModeFirstDateRange = true;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            labels.dialogRangeFirstDate,
                            style: TextStyle(
                                fontFamily: "playfair-regular",
                                fontSize: 12,
                                color: textColor),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            "$dateFirstDate $monthFirstDate, $yearFirstDate",
                            style: TextStyle(
                                fontFamily: "playfair-regular",
                                color: isSelectedModeFirstDateRange
                                    ? textColor
                                    : textColor.withAlpha(150),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isSelectedModeFirstDateRange = false;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            labels.dialogRangeLastDate,
                            style: TextStyle(
                                fontFamily: "playfair-regular",
                                fontSize: 12,
                                color: textColor),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            "$dateEndDate $monthEndDate, $yearEndDate",
                            style: TextStyle(
                                fontFamily: "playfair-regular",
                                color: isSelectedModeFirstDateRange
                                    ? textColor.withAlpha(150)
                                    : textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (mode == SomeMode.Single) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Selected Date",
                          style: TextStyle(
                              fontFamily: "playfair-regular",
                              fontSize: 12,
                              color: textColor),
                        ),
                        Text(
                          "$dateFirstDate $monthFirstDate, $yearFirstDate",
                          style: TextStyle(
                              fontFamily: "playfair-regular",
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Selected Date",
                          style: TextStyle(
                              fontFamily: "playfair-regular",
                              fontSize: 12,
                              color: textColor),
                        ),
                        Text(
                          "$monthFirstDate, $yearFirstDate",
                          style: TextStyle(
                              fontFamily: "playfair-regular",
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Divider(
            color: Color(0xffdedede),
            height: 1,
          ),
          SizedBox(
            height: 14,
          ),
        ],
      ),
      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      content: Container(
        height: heightContainer.toDouble(),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            if (mode != SomeMode.Multi) ...[
              Text(
                "$month, $year",
                style: TextStyle(
                    fontFamily: "playfair-regular",
                    fontSize: 14.2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: textColor),
              ),
            ],
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                      height: heightContainer.toDouble(), child: pageView),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    elevation: 0,
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    onPressed: () {
                      if (mode == SomeMode.Multi || mode == SomeMode.Range) {
                        if (isBlackout) blackoutDates = selectedDates;
                        done(isBlackout ? blackoutDates : selectedDates);
                        blackoutDates.clear();
                      } else if (mode == SomeMode.Single) {
                        done(selectedDate);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        labels.dialogDone,
                        style: TextStyle(
                            fontFamily: "Avenir",
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      labels.dialogCancel,
                      style: TextStyle(
                          fontFamily: "Avenir",
                          fontSize: 14,
                          color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

library some_calendar;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar_page.dart';
import 'package:some_calendar/some_date_range.dart';
import 'package:some_calendar/some_utils.dart';

typedef void OnTapFunction(DateTime date);
typedef void OnDoneFunction(
    selectedDates, blackoutDates, blackoutDays, blackoutMonths);

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
  final bool blockManyDates;

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
    this.blockManyDates = false,
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

    if (textColor == null) textColor = Colors.black;
    if (blackoutColor == null) blackoutColor = Colors.grey;
    if (primaryColor == null) primaryColor = Color(0xff365535);
    if (mode == SomeMode.Range) {
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
      return show();
  }

  void rebuildPage() {
    pageView = PageView.builder(
      controller: controller,
      physics: NeverScrollableScrollPhysics(),
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
          isBlackout: isBlackout,
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

  bool isLessThan10Days(DateTime date, DateTime newDate) {
    if (widget.blockManyDates && date.difference(newDate).inDays.abs() >= 10) {
      Fluttertoast.showToast(
        msg: 'Unable to select more then 10 days',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16,
      );
      firstRangeDate = newDate;
      endRangeDate = newDate;
      return false;
    } else {
      return true;
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
        done(selectedDates, blackoutDates, blackoutDays, blackoutMonths);
      }
    } else if (mode == SomeMode.Single) {
      selectedDate = a;
      setState(() {
        dateFirstDate = Jiffy(selectedDate).format("dd");
        monthFirstDate = Jiffy(selectedDate).format("MMM");
        yearFirstDate = Jiffy(selectedDate).format("yyyy");
        if (isWithoutDialog) {
          done(selectedDates, blackoutDates, blackoutDays, blackoutMonths);
        }
      });
    } else {
      if (endRangeDate == null && firstRangeDate == null) {
        // first date selected
        endRangeDate = a;
        firstRangeDate = a;
      } else if (!includesBlackoutDate(a, endRangeDate, firstRangeDate)) {
        if (endRangeDate.isAtSameMomentAs(firstRangeDate)) {
          if (endRangeDate.isAfter(a)) {
            // Single date, a is before endDate
            if (isLessThan10Days(endRangeDate, a)) {
              firstRangeDate = a;
            }
          } else if (endRangeDate.isAtSameMomentAs(a)) {
            // Single date, a is same as endDate/firstDate
            endRangeDate = null;
            firstRangeDate = null;
          } else {
            // Single date, a is after firstDate
            if (isLessThan10Days(firstRangeDate, a)) {
              endRangeDate = a;
            }
          }
        } else if (endRangeDate.isAtSameMomentAs(a) ||
            firstRangeDate.isAtSameMomentAs(a) &&
                (endRangeDate.day - firstRangeDate.day).abs() == 1) {
          // a is same as endDate, and there is a range
          endRangeDate = a;
          firstRangeDate = a;
        } else if (firstRangeDate.isAtSameMomentAs(a) &&
            (endRangeDate.day - firstRangeDate.day).abs() >= 1) {
          // a is same as firstDate, and there is a range
          endRangeDate = a;
          firstRangeDate = a;
        } else if ((endRangeDate.day - a.day).abs() >
            (firstRangeDate.day - a.day).abs()) {
          // a is closer to firstDate
          if (isLessThan10Days(endRangeDate, a)) {
            firstRangeDate = a;
          }
        } else {
          // a is closer to endDate
          if (isLessThan10Days(firstRangeDate, a)) {
            endRangeDate = a;
          }
        }
      } else if (!isBlackoutDate(a)) {
        // Blackout day between old dates and a
        endRangeDate = a;
        firstRangeDate = a;
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
        done(selectedDates, blackoutDates, blackoutDays, blackoutMonths);
      }
    }
  }

  bool includesBlackoutDate(DateTime newDate, endRangeDate, firstRangeDate) {
    // What date should be updated
    bool updateFirst = false;
    if (endRangeDate.isAtSameMomentAs(firstRangeDate)) {
      if (endRangeDate.isAfter(newDate)) {
        updateFirst = true;
      }
    } else if ((endRangeDate.day - newDate.day).abs() >
        (firstRangeDate.day - newDate.day).abs()) {
      updateFirst = true;
    }

    List<DateTime> dateRange = [];
    if (updateFirst) {
      dateRange = generateDateRange(
          newDate.isBefore(firstRangeDate) ? newDate : firstRangeDate,
          newDate.isAfter(firstRangeDate) ? newDate : firstRangeDate);
    } else {
      dateRange = generateDateRange(
          newDate.isBefore(endRangeDate) ? newDate : endRangeDate,
          newDate.isAfter(endRangeDate) ? newDate : endRangeDate);
    }

    for (int month in blackoutMonths) {
      for (DateTime date in dateRange) {
        if (date.month == month) {
          return true;
        }
      }
    }
    for (int dayOfWeek in blackoutDays) {
      for (DateTime date in dateRange) {
        if (date.weekday == 7 ? 0 == dayOfWeek : date.weekday == dayOfWeek) {
          return true;
        }
      }
    }
    for (DateTime date in dateRange) {
      if (blackoutDates.contains(date)) {
        return true;
      }
    }
    return false;
  }

  bool isBlackoutDate(DateTime date) {
    for (int month in blackoutMonths) {
      if (date.month == month) {
        return true;
      }
    }
    for (int dayOfWeek in blackoutDays) {
      if (date.weekday == 7 ? 0 == dayOfWeek : date.weekday == dayOfWeek) {
        return true;
      }
    }
    if (blackoutDates.contains(date)) {
      return true;
    }
    return false;
  }

  List<DateTime> generateDateRange(firstDate, lastDate) {
    List<DateTime> dates = [];
    int diff = lastDate.difference(firstDate).inDays.abs() + 1;
    DateTime date = firstDate;
    for (int i = 0; i < diff; i++) {
      dates.add(date);
      date = Jiffy(date).add(days: 1);
    }
    return dates;
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
    done(selectedDates, blackoutDates, blackoutDays, blackoutMonths);
  }

  void monthCallback(int monthNum) {
    if (blackoutMonths.contains(monthNum)) {
      setState(() {
        blackoutMonths.remove(monthNum);
      });
    } else {
      setState(() {
        blackoutMonths.add(monthNum);
      });
    }
    rebuildPage();
    done(selectedDates, blackoutDates, blackoutDays, blackoutMonths);
  }

  void generateListDateRange() {
    if (firstRangeDate != null && endRangeDate != null) {
      var diff = endRangeDate.difference(firstRangeDate).inDays + 1;
      var date = firstRangeDate;
      for (int i = 0; i < diff; i++) {
        selectedDates.add(date);
        date = Jiffy(date).add(days: 1);
      }
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
    int monthNum =
        someDateRange == null ? now.month : someDateRange.startDate.month;
    int yearNum =
        someDateRange == null ? now.year : someDateRange.startDate.year;
    bool isFirstMonth =
        monthNum != startDate.month || yearNum != startDate.year;
    bool isLastMonth =
        monthNum + 1 == lastDate.month && yearNum == lastDate.year;
    return Container(
      height: heightContainer.toDouble(),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Opacity(
                opacity: isFirstMonth ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: InkWell(
                    highlightColor: isFirstMonth ? Colors.transparent : null,
                    borderRadius: BorderRadius.circular(100),
                    onTap: !isFirstMonth
                        ? null
                        : () => {
                              controller.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeIn),
                            },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isBlackout && blackoutMonths.contains(monthNum)
                          ? primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    child: InkWell(
                      onTap: isBlackout
                          ? () => {
                                monthCallback(monthNum),
                              }
                          : null,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: "playfair-regular",
                              fontSize: 14.2,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: isBlackout &&
                                      blackoutMonths.contains(monthNum)
                                  ? Colors.white
                                  : textColor,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '$month',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
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
              Opacity(
                opacity: isLastMonth ? 0 : 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    highlightColor: isLastMonth ? Colors.transparent : null,
                    borderRadius: BorderRadius.circular(100),
                    onTap: isLastMonth
                        ? null
                        : () => {
                              controller.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeIn),
                            },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
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
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
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
                                color: textColor.withAlpha(150),
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
                        done(selectedDates, blackoutDates, blackoutDays,
                            blackoutMonths);
                        blackoutDates.clear();
                      } else if (mode == SomeMode.Single) {
                        done(selectedDates, blackoutDates, blackoutDays,
                            blackoutMonths);
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

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar.dart';

class MainRangeWithoutDialog extends StatefulWidget {
  @override
  _MainRangeWithoutDialogState createState() => _MainRangeWithoutDialogState();
}

class _MainRangeWithoutDialogState extends State<MainRangeWithoutDialog> {
  DateTime selectedDate = DateTime.now();
  List<DateTime> selectedDates = List();
  List<DateTime> blackoutDates = [
    DateTime.parse('2020-07-09'),
    DateTime.parse('2020-07-10'),
    DateTime.parse('2020-07-11'),
  ];
  List<int> blackoutDays = [
    2,
    3,
    4,
    5,
  ];
  List<int> blackoutMonths = [
    1,
    2,
    3,
    10,
    11,
    12,
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Somecalendar range without dialog"),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18),
                child: SomeCalendar(
                  primaryColor: Color(0xff5833A5),
                  mode: SomeMode.Range,
                  isWithoutDialog: true,
                  selectedDates: selectedDates,
                  blackoutDates: blackoutDates,
                  blackoutDays: blackoutDays,
                  blackoutMonths: blackoutMonths,
                  startDate: Jiffy().subtract(years: 3),
                  lastDate: Jiffy().add(months: 9),
                  done: (date) {
                    setState(() {
                      selectedDates = date;
                      showSnackbar(selectedDates.toString());
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSnackbar(String x) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(x),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar.dart';

class MainMultiWithoutDialog extends StatefulWidget {
  @override
  _MainMultiWithoutDialogState createState() => _MainMultiWithoutDialogState();
}

class _MainMultiWithoutDialogState extends State<MainMultiWithoutDialog> {
  DateTime selectedDate = DateTime.now();
  List<DateTime> selectedDates = List();
  List<DateTime> blackoutDates = [
    DateTime.parse('2020-07-09'),
    DateTime.parse('2020-07-10'),
    DateTime.parse('2020-07-11'),
  ];
  List<DateTime> purchasedDates = [
    DateTime.parse('2020-07-15'),
    DateTime.parse('2020-07-18'),
    DateTime.parse('2020-07-23'),
    DateTime.parse('2020-07-24'),
    DateTime.parse('2020-07-25'),
  ];
  List<int> blackoutDays = [
    1,
    7,
  ];
  List<int> blackoutMonths = [
    1,
    2,
    3,
    10,
    11,
    12,
  ];

  bool isBlackout = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Somecalendar multi without dialog"),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18),
                child: SomeCalendar(
                  primaryColor: Color(0xff5833A5),
                  mode: SomeMode.Multi,
                  isWithoutDialog: true,
                  selectedDates: selectedDates,
                  blackoutDates: blackoutDates,
                  blackoutDays: blackoutDays,
                  blackoutMonths: blackoutMonths,
                  purchasedDates: purchasedDates,
                  startDate: Jiffy().subtract(years: 3),
                  lastDate: Jiffy().add(months: 9),
                  isBlackout: isBlackout,
                  done: (date) {
                    setState(() {
                      if (!isBlackout) {
                        selectedDates = date;
                        showSnackbar(selectedDates.toString());
                      } else {
                        blackoutDates = date;
                        showSnackbar('blackout dates: $blackoutDates');
                      }
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

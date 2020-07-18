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
    1,
  ];
  List<int> blackoutMonths = [
    1,
    8,
  ];
  bool isBlackout = false;

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
                  primaryColor: Color.fromRGBO(2, 2, 2, 1),
                  mode: SomeMode.Range,
                  isWithoutDialog: true,
                  selectedDates: selectedDates,
                  blackoutDates: blackoutDates,
                  blackoutDays: blackoutDays,
                  blackoutMonths: blackoutMonths,
                  startDate: Jiffy().startOf(Units.MONTH),
                  lastDate: Jiffy(Jiffy().add(months: 13)).startOf(Units.MONTH),
                  isBlackout: isBlackout,
                  done: (selectedDates, blackoutDates, blackoutDays,
                      blackoutMonths) {
                    setState(() {
                      selectedDates = selectedDates;
                      blackoutDates = blackoutDates;
                      blackoutDays = blackoutDays;
                      blackoutMonths = blackoutMonths;
                      print(selectedDates);
                      print(blackoutDates);
                      print(blackoutDays);
                      print(blackoutMonths);
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

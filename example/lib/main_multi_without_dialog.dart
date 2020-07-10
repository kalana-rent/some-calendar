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
  List<DateTime> blackoutDates = [];
  List<int> blackoutDays = [];
  List<int> blackoutMonths = [];

  bool isBlackout = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print(
        Jiffy(Jiffy().add(months: 13)).startOf(Units.MONTH).toIso8601String());
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
                  primaryColor: Color.fromRGBO(2, 2, 2, 1),
                  mode: SomeMode.Multi,
                  isWithoutDialog: true,
                  selectedDates: selectedDates,
                  blackoutDates: blackoutDates,
                  blackoutDays: blackoutDays,
                  blackoutMonths: blackoutMonths,
                  startDate: Jiffy().startOf(Units.DAY),
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
                  blackoutColor: Color.fromRGBO(112, 112, 112, 1),
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

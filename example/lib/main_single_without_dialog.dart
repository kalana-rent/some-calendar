import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar.dart';

class MainSingleWithoutDialog extends StatefulWidget {
  @override
  _MainSingleWithoutDialogState createState() =>
      _MainSingleWithoutDialogState();
}

class _MainSingleWithoutDialogState extends State<MainSingleWithoutDialog> {
  DateTime selectedDate = DateTime.now();
  List<DateTime> selectedDates = List();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Somecalendar single without dialog"),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18),
                child: SomeCalendar(
                  primaryColor: Color.fromRGBO(2, 2, 2, 1),
                  textColor: Colors.red,
                  mode: SomeMode.Single,
                  isWithoutDialog: true,
                  selectedDate: selectedDate,
                  startDate: Jiffy().startOf(Units.DAY),
                  lastDate: Jiffy(Jiffy().add(months: 13)).startOf(Units.MONTH),
                  scrollDirection: Axis.horizontal,
                  done: (selectedDates) {
                    setState(() {
                      selectedDates = selectedDates;
                      print(selectedDates);
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

# some calendar
[![pub package](https://img.shields.io/pub/v/some_calendar.svg)](https://pub.dev/packages/some_calendar#-readme-tab-)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
[![support](https://img.shields.io/badge/platform-flutter%7Cflutter%20web-ff69b4.svg?style=flat-square)](https://github.com/agryva/Some-Calendar)

Custom calendar dialog widget for flutter with (multi select, single select, date range) mode

## New Features
+ Fixed issue #12
+ Fixed Issue #11
+ and add Key variable in constructor #10
+ Thank you for the support of all of you :)
+ you can change weeks label format based on localization thank you :tada:. [digit81] (https://github.com/digit81)


## Help Maintenance
I've taken the time to make this library, help support to develop it or buy me coffee and snacks to be even more enthusiastic
<br/>
<a href="https://www.buymeacoffee.com/agryva" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>
[![Paypal](https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png)](https://paypal.me/agryva)

## <a name="#gif"></a>Gif Somecalendar (without Dialog)

| <img src="https://raw.githubusercontent.com/agryva/Some-Calendar/master/screen/multi_without.gif" width="379px;"/><br /><sub><b>Multi</b></sub> | <img src="https://raw.githubusercontent.com/agryva/Some-Calendar/master/screen/range_without.gif" width="379px;"/><br /><sub><b>Range</b></sub> | <img src="https://raw.githubusercontent.com/agryva/Some-Calendar/master/screen/single_without.gif" width="379px;"/><br /><sub><b>Single</b></sub> |
| :---: | :---: | :---: |


## <a name="#gifDialog"></a>Gif Somecalendar (Dialog)

| <img src="https://raw.githubusercontent.com/agryva/Some-Calendar/master/screen/multi.gif" width="379px;"/><br /><sub><b>Multi</b></sub> | <img src="https://raw.githubusercontent.com/agryva/Some-Calendar/master/screen/range.gif" width="379px;"/><br /><sub><b>Range</b></sub> | <img src="https://raw.githubusercontent.com/agryva/Some-Calendar/master/screen/single.gif" width="379px;"/><br /><sub><b>Single</b></sub> |
| :---: | :---: | :---: |


## <a name="#getting-started"></a>Requirements to run the demo ##

### Setup
Add dependency to your pubspec.yaml:

```dart
some_calendar: ^{latest_version}
```

### Basic use
First, add an import to your code:
```dart
import 'package:some_calendar/some_calendar.dart';
```

### Setting Locale
First, add an import to your code:
```dart
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

  @override
  void initState() {
    initializeDateFormatting();
    Intl.systemLocale = 'en_En'; // to change the calendar format based on localization
    super.initState();
  }

```

### Without dialog
Single Mode, add to your code:
```dart
    Padding(
        padding: EdgeInsets.all(18),
        child: SomeCalendar(
            primaryColor: Color(0xff5833A5),
            mode: SomeMode.Single,
            scrollDirection: Axis.horizontal,
            isWithoutDialog: true,
            selectedDate: selectedDate,
            startDate: Jiffy().subtract(years: 3),
            lastDate: Jiffy().add(months: 9),
            done: (date) {
                setState(() {
                    selectedDate = date;
                    showSnackbar(selectedDate.toString());
                });
            },
        ),
    )
```

Multi Mode, add to your code:
```dart
    Padding(
        padding: EdgeInsets.all(18),
        child: SomeCalendar(
            primaryColor: Color(0xff5833A5),
            mode: SomeMode.Multi,
            isWithoutDialog: true,
            selectedDates: selectedDates,
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
```

Range Mode, add to your code:
```dart
    Padding(
        padding: EdgeInsets.all(18),
        child: SomeCalendar(
            primaryColor: Color(0xff5833A5),
            mode: SomeMode.Range,
            isWithoutDialog: true,
            selectedDates: selectedDates,
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
```

### with dialog
Single Mode, add to your code:
```dart
    showDialog(
        context: context,
        builder: (_) => SomeCalendar(
          mode: SomeMode.Single,
          isWithoutDialog: false,
          selectedDate: selectedDate,
          startDate: Jiffy().subtract(years: 3),
          lastDate: Jiffy().add(months: 9),
          done: (date) {
            setState(() {
              selectedDate = date;
              showSnackbar(selectedDate.toString());
            });
          },
        ));
```

Multi Mode, add to your code:
```dart
    showDialog(
        context: context,
        builder: (_) => SomeCalendar(
          mode: SomeMode.Multi,
          startDate: Jiffy().subtract(years: 3),
          lastDate: Jiffy().add(months: 9),
          isWithoutDialog: false,
          selectedDates: selectedDates,
          done: (date) {
            setState(() {
              selectedDates = date;
              showSnackbar(selectedDates.toString());
            });
          },
        ));
```

Range Mode, add to your code:
```dart
    showDialog(
        context: context,
        builder: (_) => SomeCalendar(
          mode: SomeMode.Range,
          startDate: Jiffy().subtract(years: 3),
          lastDate: Jiffy().add(months: 9),
          selectedDates: selectedDates,
          isWithoutDialog: false,
          primaryColor: Colors.red,
          done: (date) {
            setState(() {
              selectedDates = date;
              showSnackbar(selectedDates.toString());
            });
          },
        ));
```

## SomeMode
| SomeMode |
| :---------------------- |
| Range
| Single
| Multi

## Parameters
| parameter                   | types           | defaultValues                                                                                                     |
| :---------------------- | :-------------: | :---------------------------------------------------------------------------------------------------------------: |
| primaryColor        | `color`        | Color(0xff365535) |
| textColor        | `color`        | Colors.black |
| selectedDate       | `Date`     | Date.now() |
| selectedDates| `Date[]`     | Date.now() + 4 days|
| isWithoutDialog| `bool`     | true|
| scrollDirection| `Axis`     | Axis.vertical|
| startDate| `Date`     | |
| lastDate| `Date`     | |
| mode| `SomeMode`     |  |


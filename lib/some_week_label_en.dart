import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SomeWeekLabelEN extends StatelessWidget {
  final Color? textColor;

  const SomeWeekLabelEN({Key? key, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Text(
          "M",
          textAlign: TextAlign.center,
          style: textStyle(),
        )),
        Expanded(
            child:
                Text("T", textAlign: TextAlign.center, style: textStyle())),
        Expanded(
            child:
                Text("W", textAlign: TextAlign.center, style: textStyle())),
        Expanded(
            child:
                Text("Th", textAlign: TextAlign.center, style: textStyle())),
        Expanded(
            child:
                Text("F", textAlign: TextAlign.center, style: textStyle())),
        Expanded(
            child:
                Text("S", textAlign: TextAlign.center, style: textStyle())),
        Expanded(
            child:
                Text("Su", textAlign: TextAlign.center, style: textStyle())),
      ],
    );
  }

  TextStyle textStyle() => TextStyle(
      fontFamily: "playfair-regular",
      fontSize: 14.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      color: textColor);
}

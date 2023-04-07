import 'package:flutter/material.dart';

class CenterBoldText extends StatelessWidget {
  final String data;
  // final TextStyle style;

  CenterBoldText(
    this.data, {
    TextStyle style = const TextStyle(),
  })
  // : style = style.copyWith(
  //         fontFamily: 'Monospace',
  //         fontSize: 12,
  //       )
  ;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
    );
  }
}

class BoldButtonText extends StatelessWidget {
  final String data;

  BoldButtonText(
    this.data, {
    TextStyle style = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      // textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}

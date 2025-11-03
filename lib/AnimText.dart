// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';

Widget AnimText(
  String text, {
  required TextStyle style,
  Duration duration = const Duration(milliseconds: 500),
  Curve curve = Curves.easeInOut,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) {
  return AnimatedDefaultTextStyle(
    duration: duration,
    curve: curve,
    style: style,
    child: Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    ),
  );
}

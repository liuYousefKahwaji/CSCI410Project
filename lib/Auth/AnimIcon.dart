// ignore: file_names
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget AnimIcon(
  Color themeColor,
  IconData themeIcon,
  IconData selectIcon,
){

  return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Icon(selectIcon, color: themeColor, size: 23, key: ValueKey('${themeIcon}_${themeColor.value}')),
              );
}
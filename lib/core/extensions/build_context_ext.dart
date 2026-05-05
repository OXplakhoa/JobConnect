import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  GoRouter get router => GoRouter.of(this);
}

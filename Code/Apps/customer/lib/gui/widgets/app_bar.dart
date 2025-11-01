import 'package:ezbus/gui/widgets/animated_back_button.dart';
import 'package:ezbus/main.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/utils/app_theme.dart';

AppBar buildAppBar(BuildContext context, String title, {Widget? left, Widget? right, TextDirection? textDirection}) {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 65,
    leadingWidth: 65,
    backgroundColor: AppTheme.backgroundColor,
    iconTheme: const IconThemeData(
      color: AppTheme.colorSecondary,
    ),
    actions: [
      right ?? Container(),
    ],
    leading: const AnimatedBackButton(),
    elevation: 0,
    title:
    Text(
      title,
      style: AppTheme.title,
      textDirection: textDirection ?? (MainApp.isRtl(context) ? TextDirection.rtl : TextDirection.ltr),
    ),
  );
}
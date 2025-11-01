import 'package:ezbusdriver/gui/widgets/animated_back_button.dart';
import 'package:flutter/material.dart';
import 'package:ezbusdriver/utils/app_theme.dart';

AppBar buildAppBar(BuildContext context, String title, {Widget? left, Widget? right}) {
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
    ),
  );
}
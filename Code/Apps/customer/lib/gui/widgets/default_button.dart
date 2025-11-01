import 'package:flutter/material.dart';
import 'package:ezbus/utils/app_theme.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key? key,
    this.text,
    this.press,
  }) : super(key: key);
  final String? text;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppTheme.darkPrimary,
        ),
        onPressed: () {
          press!();
        },
        child: Text(
          text!,
          style: TextStyle(
            fontSize: 18.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

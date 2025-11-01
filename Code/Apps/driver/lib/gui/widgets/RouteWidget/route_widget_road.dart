import 'package:ezbusdriver/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/utils/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezbusdriver/gui/widgets/direction_positioned.dart';

class RouteWidgetRoad extends RouteWidgetChild{
  final Widget leading;
  final Widget trailing;
  const RouteWidgetRoad({super.key, required this.leading, required this.trailing});
  @override
  double get height => 30.h;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 40.h,
      width: 260.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DirectionPositioned(
            left: 66.w,
            child: const Icon(
              Icomoon.roadSolid,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          DirectionPositioned(
              top: 5.h,
              left: 24.w,
              child: leading
          ),
          DirectionPositioned(
              left: 115.w,
              top:5,
              child: trailing
          ),
        ],
      ),
    );
  }
}
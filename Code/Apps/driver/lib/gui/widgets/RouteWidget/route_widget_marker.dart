import 'package:ezbusdriver/gui/widgets/RouteWidget/route_widget_child.dart';
import 'package:ezbusdriver/utils/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezbusdriver/gui/widgets/direction_positioned.dart';

import '../../../utils/app_theme.dart';

class RouteWidgetMarker extends RouteWidgetChild{
  final Widget leading;
  final Widget trailing;
  const RouteWidgetMarker({super.key, required this.leading, required this.trailing});
  @override
  double get height => 40;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 40.h,
      width: 260.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DirectionPositioned(
            left: 65.5.w,
            child: Icon(
              Icomoon.routeWidgetMarker,
              color: AppTheme.colorSecondary,
              size: 35,
              shadows: <Shadow>[
                Shadow(
                    color: AppTheme.darkGrey.withOpacity(0.5),
                    blurRadius: 4.0,
                    offset: const Offset(0.0, 4.0))
              ],
            ),
          ),
          DirectionPositioned(
              top: 5.h,
              left: 24.w,
              child: leading
          ),
          DirectionPositioned(
              left: 110.w,
              top:5,
              child: trailing
          ),
        ],
      ),
    );
  }
}

import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:ezbusdriver/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';
import '../widgets/trip_time_line.dart';

class TripTimelineScreen extends StatefulWidget {
  final int? tripID;

  const TripTimelineScreen({Key? key, this.tripID}) : super(key: key);

  @override
  TripTimelineScreenState createState() => TripTimelineScreenState();
}
class TripTimelineScreenState extends State<TripTimelineScreen> {
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getPlannedTripDetailsEndpoint(widget.tripID);
      });
    });
  }
  Widget displayTripTimeline() {
    if (thisAppModel.plannedTripDetailsLoadingState.inLoading()) {
      // loading. display animation
      return loadingScreen(context);
    }
    else if (thisAppModel.plannedTripDetailsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.plannedTripDetailsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.plannedTripDetailsLoadingState.failState);
      }
      else {
        List<dynamic>? plannedTripDetails  = thisAppModel.plannedTrip?.plannedTripDetail;
        if (plannedTripDetails == null) {
          return failedScreen(context, FailState.GENERAL);
        }
        return Container(
          color: AppTheme.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: //stops
            [
              SizedBox(height: 40.h,),
              TripTimeLine(plannedTripDetails: plannedTripDetails),
            ],
          ),
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.tripTimeline ?? "Trip Timeline"),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayTripTimeline();
          }),
    );
  }

}

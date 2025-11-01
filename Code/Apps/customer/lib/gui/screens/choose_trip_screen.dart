
import 'package:ezbus/gui/screens/pay_for_trip_screen.dart';
import 'package:ezbus/gui/screens/seats_screen.dart';
import 'package:ezbus/gui/screens/trip_timeline_screen.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_road.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';
import 'package:ezbus/model/place.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/gui/widgets/app_bar.dart';
import 'package:ezbus/model/constant.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/size_config.dart';
import 'package:ezbus/utils/tools.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../connection/response/trip_search_response.dart';
import '../../model/seat.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/shimmers.dart';

class ChooseTripScreen extends StatefulWidget {

  final Place? startPlace, destinationPlace;
  final DateTime? time;

  const ChooseTripScreen({Key? key, this.startPlace, this.destinationPlace, this.time}) : super(key: key);

  @override
  ChooseTripScreenState createState() => ChooseTripScreenState();
}

class ChooseTripScreenState extends State<ChooseTripScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  Locale _locale = const Locale('en', '');
  
  @override
  void initState() {
    super.initState();
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getTripSearchEndpoint(
            widget.startPlace?.address,
            widget.destinationPlace?.address,
            widget.startPlace?.latitude,
            widget.startPlace?.longitude,
            widget.destinationPlace?.latitude,
            widget.destinationPlace?.longitude,
            widget.time);
      });
    });
  }


  Widget displayAllTripSearchResults() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.chooseYourTrip ?? 'Choose your trip'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displayTripSearchResults(context)!;
            },
          )),
    );
  }

  Widget? displayTripSearchResults(BuildContext context) {
    if (thisAppModel.tripSearchLoadingState.inLoading()) {
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().vListOptions(3),
      );
      return shimmer;
    } else if (thisAppModel.tripSearchLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.tripSearchLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.tripSearchLoadingState.failState!);
      }
      else {
        if (thisAppModel.tripSearchResults.isEmpty) {
          return emptyScreen();
        }
        return ListView.builder(
            itemCount: thisAppModel.tripSearchResults.length,
            itemBuilder: (context, index) {
              Widget ticketWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      intl.DateFormat('EEEE, dd MMMM', _locale.languageCode)
                          .format(DateTime.parse(
                          thisAppModel.tripSearchResults[index]
                              .plannedStartDate!)),
                      style: AppTheme.textGreyLarge,),
                  ),
                  SizedBox(height: 10.h,),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 270.h,
                          child: Stack(
                            children: [
                              DirectionPositioned(
                                left: 0,
                                child: RouteWidget(
                                  children: [
                                    RouteWidgetDashedLine(
                                      walking: true,
                                      trailing: Text(
                                        "${Tools.formatDouble(thisAppModel
                                            .tripSearchResults[index]
                                            .distanceToStartStop)} Km",
                                        style: AppTheme.textGreySmall,
                                      ),
                                      heightParam: 35,
                                    ),
                                    RouteWidgetMarker(
                                      leading: Text(
                                        Tools.formatTime(thisAppModel
                                            .tripSearchResults[index]
                                            .plannedStartTime),
                                        textDirection: TextDirection.ltr,
                                        style: AppTheme.textDarkBlueSmall,
                                      ),
                                      trailing: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: Text(
                                              thisAppModel
                                                  .tripSearchResults[index]
                                                  .startStop!.name!,
                                              style: AppTheme
                                                  .textDarkBlueMedium,
                                            ),
                                          ),
                                          SizedBox(height: 5.h),
                                          SizedBox(
                                            width: 200.w,
                                            child: Text(
                                              thisAppModel
                                                  .tripSearchResults[index]
                                                  .startStop!.address!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTheme.textGreySmall,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    RouteWidgetDashedLine(
                                      walking: false,
                                      trailing: Container(),
                                      heightParam: 35,
                                    ),
                                    RouteWidgetRoad(
                                      leading: Container(),
                                      trailing: Align(
                                        alignment: AlignmentDirectional
                                            .centerStart,
                                        child: Text(
                                          thisAppModel.tripSearchResults[index]
                                              .route!.name!,
                                          style: AppTheme.textDarkBlueMedium,
                                        ),
                                      ),
                                    ),
                                    RouteWidgetDashedLine(
                                      trailing: Text(
                                        "${Tools.formatDouble(thisAppModel
                                            .tripSearchResults[index]
                                            .distance)} Km",
                                        style: AppTheme.textGreySmall,
                                      ),
                                      walking: false,
                                      heightParam: 35,
                                    ),
                                    RouteWidgetMarker(
                                      leading: Text(
                                        Tools.formatTime(thisAppModel
                                            .tripSearchResults[index]
                                            .plannedEndTime),
                                        textDirection: TextDirection.ltr,
                                        style: AppTheme.textDarkBlueSmall,
                                      ),
                                      trailing: Align(
                                        alignment: AlignmentDirectional
                                            .centerStart,
                                        child: Text(
                                          thisAppModel.tripSearchResults[index]
                                              .endStop!.name!,
                                          style: AppTheme.textDarkBlueMedium,
                                        ),
                                      ),
                                    ),
                                    RouteWidgetDashedLine(
                                      trailing: Text(
                                        "${Tools.formatDouble(thisAppModel
                                            .tripSearchResults[index]
                                            .distanceToEndPoint)} Km",
                                        style: AppTheme.textGreySmall,
                                      ),
                                      walking: true,
                                      heightParam: 35,
                                    ),
                                  ],
                                ),
                              ),
                              DirectionPositioned(
                                right: 10.w,
                                bottom: 10.h,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.chair,
                                      color: AppTheme.colorSecondary,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      '${thisAppModel.tripSearchResults[index]
                                          .availableSeats} seats left',
                                      style: AppTheme.textDarkBlueMedium
                                          .copyWith(
                                          color: AppTheme.colorSecondary
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 2.h,
                          width: 350.w,
                          color: AppTheme.veryLightGrey,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.0.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                onPressed: () {
                                  //Open the timeline screen
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          TripTimelineScreen(
                                            tripID: thisAppModel
                                                .tripSearchResults[index].trip
                                                ?.id,
                                            startStopID: thisAppModel
                                                .tripSearchResults[index]
                                                .startStop?.id,
                                            endStopID: thisAppModel
                                                .tripSearchResults[index]
                                                .endStop?.id,
                                          )));
                                },
                                child: const Icon(
                                  Icons.route_outlined,
                                  color: AppTheme.darkPrimary,
                                  size: 30,
                                ),
                              ),
                              thisAppModel.settings?.paymentMethod != "none" ?
                              Text(
                                Tools.formatPrice(thisAppModel,
                                    thisAppModel.tripSearchResults[index]
                                        .price!),
                                style: AppTheme.textdarkPrimaryLarge,
                              ) : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              return GestureDetector(
                onTap: () async {
                  Seat? seat;
                  if (thisAppModel.settings?.allowSeatSelection != null &&
                      thisAppModel.settings!.allowSeatSelection == true) {
                    seat = await Navigator.push(
                        context, MaterialPageRoute(
                        builder: (context) =>
                            SeatSelectionScreen(
                              tripSearchResult: thisAppModel.tripSearchResults[index],
                            )));
                    if (seat == null) {
                      return;
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PayForTripScreen(
                              tripSearchResult: thisAppModel
                                  .tripSearchResults[index],
                              startPlace: widget.startPlace,
                              destinationPlace: widget.destinationPlace,
                              seat: seat,
                            )),
                  );
                },
                child: ticketWidget,
              );
            });
      }
    }
    return null;
  }

  Widget failedScreen(BuildContext context, FailState failState) {
    return Stack(children: [
      Positioned.fill(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(),
            ],
          ),
        ),
      ),
      Container(
        constraints: BoxConstraints(
          minHeight: Tools.getScreenHeight(context) - 150,
        ),
        child: Center(
          child: onFailRequest(context, failState),
        ),
      )
    ]);
  }

  Widget emptyScreen() {
    return Stack(children: [
      Positioned.fill(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(),
            ],
          ),
        ),
      ),
      DirectionPositioned(
        top: 20.h,
        left: 10.w,
        right: 10.w,
        bottom: 10.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/no_bus.png",
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 50
                      : 150,
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.h),
              child: Column(
                children: [
                  Text(
                    translation(context)?.noTripsMatchYourSearch ?? "Oops... There aren't any trip that match your search.",
                    style: AppTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(context) {
    return displayAllTripSearchResults();
  }

  displaySegmentIcon(IconData? icon, {String? text, double? height}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.colorSecondary),
        SizedBox(height: height?? 20.h,),
        Text(text ?? "", style: AppTheme.bold14Grey60,),
        SizedBox(height: height?? 10.h,),
      ],
    );
  }
  displaySegmentDash(width, {String? text, double? height}) {
    return
      Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Dash(
            direction: Axis.horizontal,
            length: SizeConfig.screenWidth! * width,
            dashColor: Colors.grey),
        SizedBox(height: height?? 10.h,),
        Text(text ?? "", style: AppTheme.bold14Grey60,),
        SizedBox(height: height?? 10.h,),
      ],
    );
  }
  displayTripLine(BuildContext context, TripSearchResult allTripSearchResult) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        displaySegmentIcon(Icons.directions_walk),
        displaySegmentDash(0.02, text: "${Tools.formatDouble(allTripSearchResult.distanceToStartStop)} km"),
        displaySegmentIcon(Icons.location_on_outlined, text: "1:15 pm"),
        displaySegmentDash(0.05),
        displaySegmentIcon(Icons.directions_bus, text: "${Tools.formatDouble(allTripSearchResult.distance)} km"),
        displaySegmentDash(0.05),
        displaySegmentIcon(Icons.location_on_outlined, text: "3:15 pm"),
        displaySegmentDash(0.02, text: "${Tools.formatDouble(allTripSearchResult.distanceToEndPoint)} km"),
        displaySegmentIcon(Icons.directions_walk),
      ],
    );
  }

  displayTripLineVertical(BuildContext context, TripSearchResult allTripSearchResult) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.directions_walk, color: AppTheme.colorSecondary,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Dash(
                direction: Axis.vertical,
                length: SizeConfig.screenHeight! * 0.03,
                dashColor: Colors.grey),
            SizedBox(width: 10.w,),
            Text("${Tools.formatDouble(allTripSearchResult.distanceToStartStop!)} km"
              , style: AppTheme.bold14Grey60,),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppTheme.colorSecondary,),
            SizedBox(width: 10.w,),
            Text("1:15 pm", style: AppTheme.bold14Grey60,),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Dash(
                direction: Axis.vertical,
                length: SizeConfig.screenHeight! * 0.03,
                dashColor: Colors.grey),
            SizedBox(width: 10.w,),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.directions_bus, color: AppTheme.colorSecondary,),
            SizedBox(width: 10.w,),
            Text("${Tools.formatDouble(allTripSearchResult.distance!)} km"
              , style: AppTheme.bold14Grey60,),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Dash(
                direction: Axis.vertical,
                length: SizeConfig.screenHeight! * 0.03,
                dashColor: Colors.grey),
            SizedBox(width: 10.w,),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppTheme.colorSecondary,),
            SizedBox(width: 10.w,),
            Text("3:15 pm", style: AppTheme.bold14Grey60,),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Dash(
                direction: Axis.vertical,
                length: SizeConfig.screenHeight! * 0.03,
                dashColor: Colors.grey),
            SizedBox(width: 10.w,),
            Text("${Tools.formatDouble(allTripSearchResult.distanceToEndPoint!)} km"
              , style: AppTheme.bold14Grey60,),
          ],
        ),
        const Icon(Icons.directions_walk, color: AppTheme.colorSecondary,),
      ],
    );
  }

  verticalTimeLine(TripSearchResult allTripSearchResult) {
    return SizedBox(
      width: SizeConfig.screenWidth! * 0.31,
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.directions_walk, color: Colors.grey,),
              SizedBox(height: SizeConfig.screenHeight! * 0.09,),
              const Icon(Icons.directions_walk, color: Colors.grey,),
            ],
          ),
          Column(
            children: [
              Dash(
                  direction: Axis.vertical,
                  length: SizeConfig.screenHeight! * 0.025,
                  dashColor: Colors.grey),
              const Icon(Icons.location_on_outlined, color: Colors.green,),
              Dash(
                  direction: Axis.vertical,
                  length: SizeConfig.screenHeight! * 0.04,
                  dashColor: Colors.grey),
              const Icon(Icons.location_on_outlined, color: Colors.grey,),
              Dash(
                  direction: Axis.vertical,
                  length: SizeConfig.screenHeight! * 0.025,
                  dashColor: Colors.grey),
            ],
          ),
          SizedBox(width: SizeConfig.screenWidth! * 0.01,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("${Tools.formatDouble(allTripSearchResult.distanceToStartStop!)} km"
                , style: AppTheme.normal14Grey40,),
              SizedBox(height: SizeConfig.screenHeight! * 0.005,),
              Text("1:15 pm", style: AppTheme.bold14Black,),
              SizedBox(height: SizeConfig.screenHeight! * 0.045,),
              Text("3:15 pm", style: AppTheme.bold14Black,),
              SizedBox(height: SizeConfig.screenHeight! * 0.005,),
              Text("${Tools.formatDouble(allTripSearchResult.distanceToEndPoint!)} km"
                , style: AppTheme.normal14Grey40,),
            ],
          )
        ],
      ),
    );
  }
}


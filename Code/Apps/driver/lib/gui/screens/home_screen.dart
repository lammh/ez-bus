import 'dart:async';
import 'package:ezbusdriver/gui/screens/start_trip_screen.dart';
import 'package:ezbusdriver/gui/screens/trip_time_line_screen.dart';
import 'package:ezbusdriver/gui/widgets/RouteWidget/route_widget.dart';
import 'package:ezbusdriver/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:ezbusdriver/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:ezbusdriver/gui/widgets/RouteWidget/route_widget_road.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/utils/size_config.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../model/trip.dart';
import '../../utils/tools.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/my_interstitial_ad.dart';
import '../widgets/shimmers.dart';
import 'package:ezbusdriver/gui/widgets/direction_positioned.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);
  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  ThisApplicationViewModel thisApplicationModel = serviceLocator<ThisApplicationViewModel>();
  bool isLoading = false;
  bool activePostsFound = false;

  bool serviceStatus = false;
  bool hasPermission = false;

  Position? currentGPSLocation;
  bool? locationServiceStatus;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    MyInterstitialAd.createInterstitialAd();
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    checkLocationService(context).then((LocationServicesStatus value) {
      locationServiceStatus = value == LocationServicesStatus.enabled;
      if(locationServiceStatus!= null && locationServiceStatus!) {
        getLocation().then((value) {
        currentGPSLocation = value;
      });
      }
    });
    searchFocusNode.addListener(() async {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
        //await startSearch();
      }
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisApplicationModel.getDriverTripsEndpoint();
      thisApplicationModel.getNotificationsEndpoint();
      thisApplicationModel.getPaymentsEndpoint();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.getDriverTripsEndpoint();
    thisAppModel.getNotificationsEndpoint();
  }

  Future<void> _refreshData(ThisApplicationViewModel thisAppModel) {
    return Future(
            () {
          _setData(thisAppModel);
        }
    );
  }

  Widget _displayTrips(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.tripsLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().vListOptions(4),
      );
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          height: Tools.getScreenHeight(context) * 0.65,
          child:shimmer
      );
    }
    else if (thisAppModel.tripsLoadingState.loadingFinished()) {
      if (thisAppModel.tripsLoadingState.loadError != null) {
        return
          Text(translation(context)?.networkError ?? "Network error");
      }
      else {

        if(thisAppModel.myTrips.isEmpty)
        {
          return notAssignedTrips();
        }
        else {
          //filter trips without start and end time
          List<Trip> activeTrips = [];
          for (int i = 0; i < thisAppModel.myTrips.length; i++) {
            if (thisAppModel.myTrips[i].startedAt == null) {
              activeTrips.add(thisAppModel.myTrips[i]);
            }
          }

          if(activeTrips.isNotEmpty) {
            return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: Tools.getScreenHeight(context) * 0.65,
                child:
                ListView.builder(
                    itemCount: activeTrips.length,
                    itemBuilder: (context, i) {
                      return Padding(
                          padding: const EdgeInsets.all(3),
                          child: tripCard(activeTrips[i])
                      );
                    })
            );
          }
          else {
            return Text(translation(context)?.noTripsAssignedToYou ?? "No trips assigned to you yet.");
          }
        }
      }
    }
    return Container();
  }

  Widget _displayAllSections(ThisApplicationViewModel thisAppModel) {
    var items = <Widget>[];
    items.add(_displayTripsSection(thisAppModel));
    return ListView(
        children: items
    );
  }

  Widget _displayTripsSection(ThisApplicationViewModel thisAppModel) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          thisAppModel.myTrips.isNotEmpty ?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translation(context)?.trips ?? "Trips",
                style: AppTheme.title,),
            ],
          ) : Container(),
          SizedBox(height: getProportionateScreenHeight(10)),
          _displayTrips(thisAppModel)
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, ThisApplicationViewModel thisAppModel) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: ()=>_refreshData(thisAppModel),
      child: _displayAllSections(thisAppModel),
    );
  }

  @override
  Widget build(context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel,  child) {
          return _buildHomeTab(context, thisAppModel);
        });
  }

  Widget loadingScreen() {
    return
      Stack(
          children: [
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
              top: 20,
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Text(translation(context)?.loading ?? "Loading...",
                          style: AppTheme.caption,
                          textAlign: TextAlign.center,),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
      );
  }

  tripCard(Trip trip) {
    return Column(
      children: [
        SizedBox(height: 10.h,),
        Text(
          DateFormat('EEEE, dd MMMM', _locale.languageCode).format(DateTime.parse(trip.plannedDate!)),
          style: const TextStyle(
            color: AppTheme.lightPrimary,
            fontSize: 20,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        SizedBox(height: 10.h,),
        Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    width: 400.w,
                    height: 180.h,
                    child: Stack(
                      children: [
                        DirectionPositioned(
                          left: -60.w,
                          child: SizedBox(
                            width: 300.w,
                            child: Material(
                              color: Colors.transparent,
                              child: RouteWidget(
                                children: [
                                  RouteWidgetMarker(
                                    leading: const SizedBox(),
                                    trailing: SizedBox(
                                      width: 200.w,
                                      height: 50.h,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trip.plannedTripDetail?[0].stop!.name!,
                                            style: AppTheme.textDarkBlueMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5.h,),
                                          Text(
                                            trip.plannedTripDetail?[0].stop!.address!,
                                            style: AppTheme.textDarkBlueSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  RouteWidgetDashedLine(
                                    trailing: const SizedBox(),
                                    walking: false,
                                    heightParam: 20.h,
                                  ),
                                  RouteWidgetRoad(
                                    leading: const SizedBox(),
                                    trailing: Text(trip.route!.name!,
                                      style: const TextStyle(
                                        color: AppTheme.colorSecondary,
                                        fontSize: 16,
                                        fontFamily: 'Open Sans',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  RouteWidgetDashedLine(
                                    trailing: const SizedBox(),
                                    walking: false,
                                    heightParam: 20.h,
                                  ),
                                  RouteWidgetMarker(
                                    leading: const SizedBox(),
                                    trailing: SizedBox(
                                      width: 200.w,
                                      height: 50.h,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trip.plannedTripDetail?[trip.plannedTripDetail!.length-1].stop!.name!,
                                            style: AppTheme.textDarkBlueMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5.h,),
                                          Text(
                                            trip.plannedTripDetail?[trip.plannedTripDetail!.length-1].stop!.address!,
                                            style: AppTheme.textDarkBlueSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                displayDivider(),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: //row for price and button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () {
                          MyInterstitialAd.showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripTimelineScreen(
                                tripID: trip.id!,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.timeline, color: AppTheme.lightPrimary, size: 30,),
                      ),
                      //start a trip icon button
                      CupertinoButton(
                        onPressed: () {
                          MyInterstitialAd.showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StartTripScreen(routeId: trip.route!.id!, trip: trip),
                            ),
                          );
                        },
                        child: const Icon(Icons.play_arrow, color: AppTheme.darkPrimary, size: 30,),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget notAssignedTrips() {
    //image img_no_assigned_trips.png with text "No trips assigned to you yet."
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30.h,),
          Image.asset("assets/images/img_no_assigned_trips.png"
            , width: 200.w, height: 200.h,),
          SizedBox(height: 20.h,),
          Text(translation(context)?.noTripsAssignedToYou ?? "No trips assigned to you yet.",
            style: TextStyle(
              color: AppTheme.lightPrimary,
              fontSize: 20,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
        ]
      ),
    );
  }
}

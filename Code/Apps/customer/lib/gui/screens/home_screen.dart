import 'dart:async';

import 'package:ezbus/gui/screens/set_start_end_time_for_trip_screen.dart';
import 'package:ezbus/gui/widgets/my_interstitial_ad.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/utils/size_config.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../connection/utils.dart';
import '../../model/place.dart';
import '../../model/reservation.dart';
import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/favorite_place_widget.dart';
import '../widgets/no_animation_page_route.dart';
import '../widgets/recent_trip_widget.dart';
import '../widgets/shimmers.dart';
import 'set_location_on_map_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';

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

  @override
  void initState() {
    MyInterstitialAd.createInterstitialAd();
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
    if(thisApplicationModel.isLoggedIn != true) {
      thisApplicationModel.clearAllUserData();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    MyInterstitialAd.dispose();
  }

  void _setData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.getFavoritesEndpoint();
    thisAppModel.getReservationsEndpoint();
    thisAppModel.getPaymentsEndpoint();
    thisAppModel.getNotificationsEndpoint();
    // thisAppModel.getAdvertisementsEndpoint();
    // thisAppModel.getSettingsEndpoint();
  }

  Future<void> _refreshData(ThisApplicationViewModel thisAppModel) {
    return Future(
            () {
          _setData(thisAppModel);
        }
    );
  }

  Widget _displayLastTripsSection(ThisApplicationViewModel thisAppModel) {
    return Padding(
      padding: const EdgeInsets.only(left: 15,
          right: 15, top: 25,
          bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translation(context)?.lastTrips ?? "Last trips",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppTheme.textDarkBlueLarge
          ),
          SizedBox(height: 10.h),
          _displayLastTrips(thisAppModel)
        ],
      ),
    );
  }

  Widget? _displayFavorites(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.favoritePlacesLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().hListOptions(3, 0.4),
      );
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          height: 210.h,
          child:shimmer
      );
    }
    else if (thisAppModel.favoritePlacesLoadingState.loadingFinished()) {
      if (thisAppModel.favoritePlacesLoadingState.loadError != null) {
        return
          const Text("Network error");
      }
      else {

        if(thisAppModel.favoritePlaces == null || thisAppModel.favoritePlaces!.isEmpty)
        {
          return const Text("No items yet.");
        }
        else {
          return SizedBox(
              height: 136.h,
              child:
              ListView.separated(
                  padding: EdgeInsets.only(left: 10.w, top: 20.h, right: 29.w),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) {
                    return SizedBox(width: 18.w);
                  },
                  itemCount: thisAppModel.favoritePlaces!.length,
                  itemBuilder: (context, i) {
                    return Padding(
                        padding: const EdgeInsets.all(3),
                        child: FavoritePlaceWidget(
                            place: thisAppModel.favoritePlaces?[i], gpsLocation: currentGPSLocation,)
                    );
                  })
          );
        }
      }
    }
    return null;
  }

  _displayLastTrips(ThisApplicationViewModel thisAppModel) {
    if (thisAppModel.reservationsLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().hListOptions(3, 0.4),
      );
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          height: 210.h,
          child:shimmer
      );
    }
    else if (thisAppModel.reservationsLoadingState.loadingFinished()) {
      if (thisAppModel.reservationsLoadingState.loadError != null) {
        return
          const Text("Network error");
      }
      else {
        List<Reservation> reservations = [];
        reservations.addAll(thisAppModel.activeReservations);
        if(reservations.length < 5) {
          int remaining = 5 - reservations.length;
          if(thisAppModel.pastReservations.length > remaining) {
            //append to reservations past reservations with less than 3
            reservations.addAll(thisAppModel.pastReservations.sublist(0, remaining));
          }
          else {
            //append to reservations past reservations with less than 3
            reservations.addAll(thisAppModel.pastReservations);
          }
        }
        if(reservations.isEmpty)
        {
          return Text(translation(context)?.noTripsYet ?? "No trips yet.");
        }
        else {
          return Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              height: 150.h,
              child:
              ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: reservations.length,
                  itemBuilder: (context, i) {
                    return Padding(
                        padding: const EdgeInsets.all(3),
                        child: RecentTripWidget(
                          reservation: reservations[i])
                    );
                  })
          );
        }
      }
    }
    return null;
  }

  Widget _displayTop() {
    // widget with rounded corner image and a card on it
    return SafeArea(
      minimum: const EdgeInsets.only(top: 25),
      child: Padding(
          padding: EdgeInsets.only(bottom: 40.h),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 26.w, bottom: 10.h),
                    child: RichText(
                        text: TextSpan(children: [
                          WidgetSpan(
                              child: GradientText(Config.systemName,
                                  gradientDirection:
                                  GradientDirection.ttb,
                                  colors: const [
                                    AppTheme.darkPrimary,
                                    AppTheme.veryLightPrimary
                                  ],
                                  style: AppTheme.textdarkPrimaryXL))
                        ]),
                        textAlign: TextAlign.left)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset("assets/images/img_home.png",
                          height: 210.h,
                          width: 330.w,
                          alignment: Alignment.center),
                    ),
                    Container(
                      height: 10.h,
                    ),
                    SizedBox(
                      width: 295.w,
                      height: 60.h,
                      child: ElevatedButton(
                          onPressed: () {
                            MyInterstitialAd.showInterstitialAd();
                            startSearch();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.darkPrimary,
                              shape: const StadiumBorder(),
                              textStyle:
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Open Sans',
                              ),
                              elevation: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                  "assets/images/searchIcon.svg"),
                              Container(width: 7),
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.0.h),
                                child: Text(
                                  translation(context)?.startSearch ?? 'Start search',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ])
      ),
    );
  }

  Widget _displayAllSections(ThisApplicationViewModel thisAppModel) {
    var items = <Widget>[];
    items.add(_displayTop());
    //items.add(SearchBar(searchType: 0));
    //items.add(_displayEndingSoonPostsSection());
    items.add(_displayFavoritesSection(thisAppModel));
    items.add(_displayLastTripsSection(thisAppModel));
    return ListView(
        children: items
    );
  }

  Widget _displayFavoritesSection(ThisApplicationViewModel thisAppModel) {
    return Padding(
      padding: const EdgeInsets.only(left: 15,
          right: 15, top: 25,
          bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(translation(context)?.favorites ?? "Favorites",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppTheme.textDarkBlueLarge
                ),
                Padding(
                    padding:
                    EdgeInsets.only(top: 3.h, bottom: 2.h),
                    child: TextButton(
                      onPressed: () {
                        if(thisApplicationModel.isLoggedIn == false) {
                          //show a dialog to login
                          showLoginDialog(context, widget);
                        }
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                            const SetLocationOnMapScreen(
                              action: "AddFavoritePlace",)),
                          );
                        }
                      },
                      child: Text(translation(context)?.addNew ?? "+ Add new",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Color(0XFF979797),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Open Sans',
                          )
                      ),
                    ))
              ]),
          SizedBox(height: 10.h),
          _displayFavorites(thisAppModel)!
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
              top: 20.h,
              left: 10.w,
              right: 10.w,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60.h,
                    width: 60.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Column(
                      children: [
                        Text(translation(context)?.loading ?? "Loading...",
                          style: AppTheme.caption,
                          textAlign: TextAlign.center,),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
      );
  }

  Widget loadingWait() {
    return SizedBox(
      width: SizeConfig.screenWidth,
      height: 200.0.h,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> startSearch() async {
    Place? startPlace;
    Place? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            const SetLocationOnMapScreen(
              action: "SetAddress",)));
    if (result != null) {
      if (currentGPSLocation != null) {
        startPlace = Place(
            address: translation(context)?.currentLocation ?? "Current location",
            latitude: currentGPSLocation
                ?.latitude,
            longitude: currentGPSLocation
                ?.longitude);
      }
      if (context.mounted) {
        pushWithoutAnimation(
            SetStartEndTimeForTripScreen(
                startPlace: startPlace,
                destinationPlace: result),
            context);
      }
    }
  }
  Future pushWithoutAnimation<T extends Object>(Widget page, BuildContext context) {
    Route route = NoAnimationPageRoute(builder: (BuildContext context) => page);
    return Navigator.push(context, route);
  }
}

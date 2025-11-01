
import 'dart:async';

import 'package:ezbus/connection/response/trip_search_response.dart';
import 'package:ezbus/gui/screens/seats_screen.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:ezbus/model/place.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/gui/widgets/app_bar.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/tools.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/constant.dart';
import '../../model/seat.dart';
import '../../utils/size_config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';

class PayForTripScreen extends StatefulWidget {
  final TripSearchResult? tripSearchResult;
  final Place? startPlace, destinationPlace;
  final Seat? seat;
  const PayForTripScreen({Key? key, this.tripSearchResult, this.startPlace,
    this.destinationPlace, this.seat}) : super(key: key);

  @override
  PayForTripScreenState createState() => PayForTripScreenState();
}

class PayForTripScreenState extends State<PayForTripScreen> {
  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();

  Completer<GoogleMapController>? mapController = Completer();
  List<Marker> markers = [];

  BuildContext? myBuildContext;

  TextEditingController promoCodeTextEditingController = TextEditingController();
  PayMethod payMethod = PayMethod.CASH;

  @override
  void initState() {
    super.initState();
    thisAppModel.payForTripLoadingState.error = null;
    thisAppModel.applyPromoCodeLoadingState.error = null;
    thisAppModel.promoCodeDiscount = null;
  }

  Widget displayCurrentTrip() {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        myBuildContext = context;
        if(thisAppModel.applyPromoCodeLoadingState.loadingFinished() &&
        thisAppModel.applyPromoCodeLoadingState.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorToast(
                context, thisAppModel.applyPromoCodeLoadingState.error!);
            thisAppModel.applyPromoCodeLoadingState.error = null;
          });
        }
          return Scaffold(
            appBar: buildAppBar(context, translation(context)?.bookTrip ?? 'Book Trip'),
            bottomSheet: thisApplicationViewModel.settings?.paymentMethod != "none" ? displayBottomSheet(thisApplicationViewModel): null,
            body: tripOnMap(widget.tripSearchResult, thisApplicationViewModel)
          );
      },
    );


  }

  @override
  Widget build(context) {
    return displayCurrentTrip();
  }

  Widget tripOnMap(TripSearchResult? tripSearchResult, ThisApplicationViewModel thisApplicationViewModel) {
    //create google map widget with markers that show the trip
    return Stack(
      children: [
        GoogleMap(
          markers: getMarkers(),
          polylines: getPolylines(),
          initialCameraPosition: CameraPosition(
            target: tripSearchResult != null ?
            LatLng(double.parse(tripSearchResult.startStop!.lat!),
                double.parse(tripSearchResult.startStop!.lng!))
                : LatLng(
                widget.startPlace!.latitude!, widget.startPlace!.longitude!),
            zoom: 12,
          ),
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) async {
            mapController?.complete(controller);
            await adjustBounds();
          },
          onCameraIdle: () {
            //print("onCameraIdle");
          },
        ),
        thisApplicationViewModel.settings?.paymentMethod == "none" ?
        DirectionPositioned(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
          child: Container(
            height: 370.h,
            decoration: ShapeDecoration(
              color: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                    width: 0.50, color: AppTheme.lightGrey),
                borderRadius: BorderRadius.circular(13),
              ),
              shadows: const [
                BoxShadow(
                  color: AppTheme.darkGrey,
                  blurRadius: 4,
                  offset: Offset(4, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 270.h,
                  width: 300.w,
                  child: RouteWidget(
                    children: [
                      RouteWidgetDashedLine(
                        walking: true,
                        trailing: Text(
                          "${widget.tripSearchResult!
                              .distanceToStartStop!
                              .toStringAsFixed(1)} Km",
                          style: AppTheme.textGreySmall,
                        ),
                        heightParam: 50,
                      ),
                      RouteWidgetMarker(
                        leading: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            Tools.formatTime(
                                widget.tripSearchResult!
                                    .plannedStartTime),
                            textDirection: TextDirection.ltr,
                            style: AppTheme.textDarkBlueSmall,
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                widget.tripSearchResult!
                                    .startStop!.name!,
                                style: AppTheme
                                    .textDarkBlueMedium,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 170.w,
                              child: Text(
                                widget.tripSearchResult!
                                    .startStop!.address!,
                                maxLines: 1,
                                style: AppTheme.textGreySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      RouteWidgetDashedLine(
                        walking: false,
                        trailing: Text(
                          "${widget.tripSearchResult!.distance!
                              .toStringAsFixed(1)} Km",
                          style: AppTheme.textGreySmall,
                        ),
                        heightParam: 70,
                      ),
                      RouteWidgetMarker(
                        leading: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            Tools.formatTime(
                                widget.tripSearchResult!
                                    .plannedEndTime),
                            textDirection: TextDirection.ltr,
                            style: AppTheme.textDarkBlueSmall,
                          ),
                        ),
                        trailing: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            widget.tripSearchResult!.endStop!
                                .name!,
                            style: AppTheme.textDarkBlueMedium,
                          ),
                        ),
                      ),
                      RouteWidgetDashedLine(
                        trailing: Text(
                          "${widget.tripSearchResult!
                              .distanceToEndPoint!
                              .toStringAsFixed(1)} Km",
                          style: AppTheme.textGreySmall,
                        ),
                        walking: true,
                      )
                    ],
                  ),
                ),
                Container(
                  height: 2,
                  width: 350.w,
                  color: AppTheme.lightGrey,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 10.0.h, bottom: 10.0.h),
                  child: TextButton(
                      onPressed: () {
                        payForTrip(thisApplicationViewModel);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.darkPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              16),
                        ),
                        elevation: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          translation(context)?.book ?? "Book",
                          style: AppTheme.textWhiteMedium,
                        ),
                      )
                  ),
                ),
                widget.seat != null ?
                Text(
                  "Seat: ${widget.seat!.seatNumber} - row ${widget.seat!.row + 1} - columns - ${widget.seat!.column + 1}",
                  style: AppTheme.textDarkBlueSmall,
                ) : Container(),
              ],
            ),
          ),
        ) : Container()
      ],
    );
  }

  calculateCenterOfTrip(TripSearchResult tripSearchResult) {
    double centerLat = (double.parse(tripSearchResult.startStop!.lat!) +
        tripSearchResult.endPoint!.latitude) /
        2.0;
    double centerLng = (double.parse(tripSearchResult.startStop!.lng!) +
        tripSearchResult.endPoint!.longitude) /
        2.0;
    return LatLng(centerLat, centerLng);
  }

  getMarkers() {
    markers.clear();
    Marker startLocationMarker = Marker(
      markerId: const MarkerId("currentLocation"),
      position: LatLng(
        widget.startPlace!.latitude!,
        widget.startPlace!.longitude!,
      ),
      infoWindow: InfoWindow(
        title: "Start",
        snippet: widget.startPlace!.address,
      ),
      //blue marker
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    Marker startTripMarker = Marker(
      markerId: const MarkerId("startTrip"),
      position: LatLng(
        double.parse(widget.tripSearchResult!.startStop!.lat!),
        double.parse(widget.tripSearchResult!.startStop!.lng!),
      ),
      infoWindow: InfoWindow(
        title: "Pickup: ${widget.tripSearchResult!.startStop!.name!}",
        snippet: widget.tripSearchResult!.startStop!.address,
      ),
      //green marker
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker endTripMarker =   Marker(
      markerId: const MarkerId("endTrip"),
      position: LatLng(
        widget.tripSearchResult!.endPoint!.latitude,
        widget.tripSearchResult!.endPoint!.longitude,
      ),
      infoWindow: const InfoWindow(
        title: "Dropoff",
      ),
    );

    Marker endLocationMarker = Marker(
      markerId: const MarkerId("endLocation"),
      position: LatLng(
        widget.destinationPlace!.latitude!,
        widget.destinationPlace!.longitude!,
      ),
      infoWindow: InfoWindow(
        title: "Destination",
        snippet: widget.destinationPlace!.address,
      ),
      //blue marker
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    if(widget.tripSearchResult!.distanceToStartStop! > 0.2) {
      markers.add(startLocationMarker);
    }
    markers.add(startTripMarker);
    markers.add(endTripMarker);
    markers.add(endLocationMarker);

    //convert to list of markers
    Set<Marker> newMarkers = {};
    newMarkers.addAll(markers);
    return newMarkers;
  }

  Future<void> adjustBounds() async {
    LatLngBounds? boundss = getBoundsMarker();
    if(boundss != null) {
      mapController?.future.then((value) => value.animateCamera(CameraUpdate.newLatLngBounds(boundss, 150)));
    }
  }

  LatLngBounds? getBoundsMarker(){
    if(mapController==null) {
      return null;
    }
    if(markers.isEmpty || markers.length==1){
      return null;
    }

    return Tools.createBounds(markers.map((m) => m.position).toList());
  }

  getPolylines() {
    List<LatLng> routePath = widget.tripSearchResult!.path!.map((e) => LatLng(e.latitude, e.longitude)).toList();
    Polyline tripPolyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.black,
      width: 5.w.toInt(),
      points: routePath,
    );

    Polyline startTripPolyline = Polyline(
      polylineId: const PolylineId('startTrip'),
      color: Colors.green,
      //make dash
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      width: 5.w.toInt(),
      points: getLineBetweenTwoPoints(
          LatLng(widget.startPlace!.latitude!, widget.startPlace!.longitude!),
          LatLng(double.parse(widget.tripSearchResult!.startStop!.lat!), double.parse(widget.tripSearchResult!.startStop!.lng!))),
    );

    Polyline endTripPolyline = Polyline(
      polylineId: const PolylineId('endTrip'),
      color: Colors.red,
      width: 5.w.toInt(),
      //make dash
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      points: getLineBetweenTwoPoints(
          LatLng(widget.tripSearchResult!.endPoint!.latitude, widget.tripSearchResult!.endPoint!.longitude),
          LatLng(widget.destinationPlace!.latitude!, widget.destinationPlace!.longitude!)),
    );

    return {tripPolyline, startTripPolyline, endTripPolyline};
  }

  getLineBetweenTwoPoints(LatLng latLng, LatLng latLng2) {
    List<LatLng> points = [];
    points.add(latLng);
    points.add(latLng2);
    return points;
  }

  showConfirmDialog(BuildContext context, String title, String content, String u) {
    //show dialog to confirm payment
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: Text(translation(context)?.cancel ?? "Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(u),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  void showErrorDialog(BuildContext context, String s) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translation(context)?.error ?? "Error"),
            content: Text(s),
            actions: [
              TextButton(
                child: Text(translation(context)?.ok ?? "OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void showErrorToast(BuildContext context, String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> payForTrip(ThisApplicationViewModel thisApplicationViewModel) async {
    if (thisApplicationViewModel.isLoggedIn == false) {
      //show a dialog to login
      showLoginDialog(context, widget, popCount: 2);
    }
    else {
      setState(() {
        thisApplicationViewModel.payForTripLoadingState
            .error = null;
      });
      //check if the user has enough money
      if (thisApplicationViewModel.settings?.paymentMethod != "none") {
        double price = widget.tripSearchResult!.price!;
        if(thisApplicationViewModel.promoCodeDiscount != null) {
          price = widget.tripSearchResult!.price! - thisApplicationViewModel.promoCodeDiscount!;
        }
        String? promoCode = promoCodeTextEditingController.text;
        if(payMethod == PayMethod.WALLET) {
          if (thisApplicationViewModel.currentUser!
              .wallet != null &&
              thisApplicationViewModel.currentUser!
                  .wallet! >=
                  price) {
            //show confirm dialog
            showConfirmDialog(context,
                translation(context)?.bookTrip ?? "Book Trip",
                "Are you sure you want to pay ${Tools.formatPrice(
                    thisApplicationViewModel,
                    price)} from your wallet?",
                translation(context)?.book ?? "Book").then((value) {
              if (value == true) {
                thisApplicationViewModel.payForTripEndpoint(
                    myBuildContext,
                    widget.tripSearchResult!
                        .id!,
                    payMethod,
                    promoCode: promoCode,
                    seat: widget.seat);
              }
            });
          }
          else {
            //show confirm dialog
            showErrorDialog(context,
                translation(context)?.notEnoughMoney ??
                    "You don't have enough money in your wallet.");
          }
        }
        else {
          //show confirm dialog
          showConfirmDialog(context,
              translation(context)?.bookTrip ?? "Book Trip",
              "Are you sure you want to book this trip and pay ${Tools.formatPrice(
                  thisApplicationViewModel,
                  price)} in cash?",
              translation(context)?.book ?? "Book").then((value) {
            if (value == true) {
              thisApplicationViewModel.payForTripEndpoint(
                  myBuildContext,
                  widget.tripSearchResult!
                      .id!,
                  payMethod,
                  promoCode: promoCode,
                  seat: widget.seat);
            }
          });
        }
      }
      else {
        thisApplicationViewModel.payForTripEndpoint(
            myBuildContext,
            widget.tripSearchResult!
                .id!,
            payMethod,
            seat: widget.seat);
      }
    }
  }

  Widget displayBottomSheet(ThisApplicationViewModel thisApplicationViewModel) {
    return Container(
      height: 300.h,
      width: SizeConfig.screenWidth,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightGrey,
            width: 0.50,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGrey,
            blurRadius: 4,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: ShapeDecoration(
            color: AppTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                  width: 0.50, color: AppTheme.lightGrey),
              borderRadius: BorderRadius.circular(13),
            ),
            shadows: const [
              BoxShadow(
                color: AppTheme.darkGrey,
                blurRadius: 4,
                offset: Offset(4, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 190.h,
                width: 300.w,
                child: RouteWidget(
                  children: [
                    RouteWidgetDashedLine(
                      walking: true,
                      trailing: Text(
                        "${widget.tripSearchResult!
                            .distanceToStartStop!
                            .toStringAsFixed(1)} Km",
                        style: AppTheme.textGreySmall,
                      ),
                      heightParam: 30.h,
                    ),
                    RouteWidgetMarker(
                      leading: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          Tools.formatTime(
                              widget.tripSearchResult!
                                  .plannedStartTime),
                          textDirection: TextDirection.ltr,
                          style: AppTheme.textDarkBlueSmall,
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              widget.tripSearchResult!
                                  .startStop!.name!,
                              style: AppTheme
                                  .textDarkBlueMedium,
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 170.w,
                            child: Text(
                              widget.tripSearchResult!
                                  .startStop!.address!,
                              maxLines: 1,
                              style: AppTheme.textGreySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RouteWidgetDashedLine(
                      walking: false,
                      trailing: Container(),
                      heightParam: 20.h,
                    ),
                    RouteWidgetMarker(
                      leading: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          Tools.formatTime(
                              widget.tripSearchResult!
                                  .plannedEndTime),
                          textDirection: TextDirection.ltr,
                          style: AppTheme.textDarkBlueSmall,
                        ),
                      ),
                      trailing: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          widget.tripSearchResult!.endStop!
                              .name!,
                          style: AppTheme.textDarkBlueMedium,
                        ),
                      ),
                    ),
                    RouteWidgetDashedLine(
                      trailing: Text(
                        "${widget.tripSearchResult!
                            .distanceToEndPoint!
                            .toStringAsFixed(1)} Km",
                        style: AppTheme.textGreySmall,
                      ),
                      walking: true,
                      heightParam: 20.h,
                    )
                  ],
                ),
              ),
              Container(
                height: 2,
                width: 350.w,
                color: AppTheme.lightGrey,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.distance ?? "Distance",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    Text(
                      "${widget.tripSearchResult!.distance!
                          .toStringAsFixed(1)} Km",
                      style: AppTheme.bold14DarkBlue,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.price ?? "Price",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    Text(
                      Tools.formatPrice(thisApplicationViewModel,
                          widget.tripSearchResult!.price!),
                      style: AppTheme.bold14DarkBlue,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.discount ?? "Discount",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    Text(
                      thisApplicationViewModel.promoCodeDiscount != null
                          ? "${thisApplicationViewModel.promoCodeDiscount!}"
                          : "0.0",
                      style: AppTheme.bold14DarkBlue,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.total ?? "Total",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    Text(
                      thisApplicationViewModel.promoCodeDiscount != null
                          ? Tools.formatPrice(thisApplicationViewModel,
                          widget.tripSearchResult!.price! -
                              thisApplicationViewModel.promoCodeDiscount!)
                          :
                      Tools.formatPrice(thisApplicationViewModel,
                          widget.tripSearchResult!.price!),
                      style: AppTheme.bold14DarkBlue,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.paymentMethod ?? "Payment Method",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        showPaymentMethodBottomSheetDialog(context, thisApplicationViewModel);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppTheme.lightGrey, width: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        // backgroundColor: AppTheme.lightGrey,
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            payMethod == PayMethod.WALLET ? Icons.account_balance_wallet : Icons.money,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            payMethod == PayMethod.WALLET ? (translation(context)?.wallet ?? "Wallet") : (translation(context)?.cash ?? "Cash"),
                            style: AppTheme.textPrimarySmallBold,
                          ),
                        ],
                      )
                    ),
                  ],
                ),
              ),
              //apply promo code
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.promoCode ?? "Promo Code",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        //show dialog to enter promo code
                        showPromoCodeBottomSheetDialog(context, thisApplicationViewModel);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppTheme.lightGrey, width: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        // backgroundColor: AppTheme.lightGrey,
                      ),
                      child: thisApplicationViewModel.applyPromoCodeLoadingState.inLoading()?
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ):
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(
                            Icons.card_giftcard,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            translation(context)?.apply ?? "Apply",
                            style: AppTheme.textPrimarySmallBold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (thisApplicationViewModel.settings
                  ?.allowSeatSelection != null &&
                  thisApplicationViewModel.settings?.allowSeatSelection == true &&
                  widget.seat != null) ?
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translation(context)?.seatNumber ?? "Seat Number",
                        style: AppTheme.bold14DarkBlue,
                      ),
                    ),
                    Text(
                      widget.seat != null ? "${widget.seat!.seatNumber} - row ${widget.seat!.row + 1} - columns - ${widget.seat!.column + 1}" : "N/A",
                      style: AppTheme.bold14DarkBlue,
                    )
                  ],
                ),
              ) : Container(),
              Padding(
                padding: EdgeInsets.only(
                    top: 10.0.h, bottom: 30.0.h),
                child: TextButton(
                  onPressed: () {
                    payForTrip(thisApplicationViewModel);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.darkPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          16),
                    ),
                    elevation: 10,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      (translation(context)?.pay ?? "Pay") + " " +
                          (thisApplicationViewModel.promoCodeDiscount != null?
                          Tools.formatPrice(thisApplicationViewModel,
                              widget.tripSearchResult!.price! -
                                  thisApplicationViewModel.promoCodeDiscount!):
                          Tools.formatPrice(thisApplicationViewModel,
                              widget.tripSearchResult!.price!)),
                      style: AppTheme.textWhiteMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPromoCodeBottomSheetDialog(BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {
    //display a bottom sheet to enter promo code
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: SizedBox(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      translation(context)?.enterPromoCode ?? "Enter Promo Code",
                      style: AppTheme.textlightPrimaryMedium,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: promoCodeTextEditingController,
                        decoration: InputDecoration(
                          hintText: translation(context)?.promoCode ?? "Promo Code",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        //apply promo code
                        //(String? promoCode, int? plannedTripID, double? price, BuildContext context)
                        if(promoCodeTextEditingController.text.isNotEmpty) {
                          thisApplicationViewModel.applyPromoCodeEndpoint(
                              promoCodeTextEditingController.text,
                              widget.tripSearchResult!.id!,
                              widget.tripSearchResult!.price!,
                              context);
                          //dismiss the bottom sheet
                          Navigator.of(context).pop();
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.darkPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          translation(context)?.apply ?? "Apply",
                          style: AppTheme.textWhiteMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showPaymentMethodBottomSheetDialog(BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {
    //bottom sheet to select either cash or wallet
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: SizedBox(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      translation(context)?.selectPaymentMethod ?? "Select Payment Method",
                      style: AppTheme.textlightPrimaryMedium,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  translation(context)?.wallet ?? "Wallet",
                                  style: AppTheme.bold14DarkBlue,
                                ),
                              ],
                            ),
                          ),
                          Radio<PayMethod>(
                            value: PayMethod.WALLET,
                            groupValue: payMethod,
                            onChanged: (PayMethod? value) {
                              setState(() {
                                payMethod = value!;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(
                                  Icons.money,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  translation(context)?.cash ?? "Cash",
                                  style: AppTheme.bold14DarkBlue,
                                ),
                              ],
                            ),
                          ),
                          Radio<PayMethod>(
                            value: PayMethod.CASH,
                            groupValue: payMethod,
                            onChanged: (PayMethod? value) {
                              setState(() {
                                payMethod = value!;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}



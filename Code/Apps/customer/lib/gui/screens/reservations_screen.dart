
import 'dart:io';

import 'package:ezbus/gui/screens/complaint_screen.dart';
import 'package:ezbus/gui/screens/reservation_dialog.dart';
import 'package:ezbus/gui/screens/track_bus_screen.dart';
import 'package:ezbus/gui/screens/trip_timeline_screen.dart';
import 'package:ezbus/gui/widgets/tab_choice_widget.dart';
import 'package:ezbus/gui/widgets/ticket_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/gui/widgets/app_bar.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/reservation.dart';
import '../../utils/tools.dart';
import '../../widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';
class ReservationsScreen extends StatefulWidget {
  final bool? showBar;

  const ReservationsScreen({Key? key, this.showBar}): super(key: key);
  @override
  ReservationsScreenState createState() => ReservationsScreenState();
}

class ReservationsScreenState extends State<ReservationsScreen> with TickerProviderStateMixin {
  bool isLoading = false;
  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  int reservationTypeIdx = 0;

  TabController? _controller;

  PageController? _pageController;
  bool shareLoading=false;
  @override
  void initState() {
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _refreshData();
      });
    });
    super.initState();
  }

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.getReservationsEndpoint();
        }
    );
  }

  Widget displayAllReservations(ThisApplicationViewModel thisAppModel) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Center(
          child: TabChoiceWidget(
            color: AppTheme.colorSecondary,
            choices: [
              translation(context)?.active ?? "Active",
              translation(context)?.history ?? "History"
            ],
            pageController: _pageController,
          ),
        ),
        Expanded(
          child: PageView(
              controller: _pageController,
              onPageChanged: (pageIndex) {
                setState(() {
                  reservationTypeIdx = pageIndex;
                });
                _controller?.animateTo(pageIndex);
              },
              children: List.generate(2, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: displayReservations(thisAppModel, index),
                  ),
                );
              })
          ),
        ),
      ],
    );
  }

  Widget displayReservations(ThisApplicationViewModel thisAppModel, int index) {
    if (thisAppModel.isLoggedIn != true) {
      return signInOut(context, widget);
    }
    if (thisAppModel.reservationsLoadingState.inLoading()) {
      return loadingScreen();
    }
    else {
      if (thisAppModel.reservationsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.reservationsLoadingState.failState);
      }
      List<Widget> a = [];
      if (checkReservationsExist(thisAppModel, index)) {
        a.addAll(reservationsListScreen(thisAppModel, index));
      }
      else {
        a.add(Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60.h),
            Image.asset("assets/images/no_bus.png", height: MediaQuery
                .of(context)
                .orientation == Orientation.landscape ? 150 : 250,),
            Padding(
              padding: EdgeInsets.only(top: 30.h),
              child: Column(
                children: [
                  Text(translation(context)?.noTrips ?? "Oops... No trips.",
                    style: AppTheme.textGreyLarge,
                    textAlign: TextAlign.center,),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ));
      }
      if(a.isNotEmpty) {
        return ListView.separated(
          itemBuilder: (context, i) {
            return a[i];
          },
          itemCount: a.length,
          separatorBuilder: (context, i) {
            return const SizedBox(height: 10);
          },
        );
      }
      else {
        return Container();
      }
    }
  }

  bool checkReservationsExist(ThisApplicationViewModel thisAppModel, int index) {
    if (index == 0 && thisAppModel.activeReservations.isNotEmpty) {
      return true;
    }
    else
    if (index == 1 && thisAppModel.pastReservations.isNotEmpty) {
      return true;
    }
    return false;
  }
  Future<String> _getQrCode(String data) async {
    final image = await QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImageData(200.0); // Generate QR code image data

    final filename = 'qr_code.png';
    final tempDir = await getTemporaryDirectory(); // Get temporary directory to store the generated image
    final file = await File('${tempDir.path}/$filename').create(); // Create a file to store the generated image
    var bytes = image!.buffer.asUint8List(); // Get the image bytes
    await file.writeAsBytes(bytes); // Write the image bytes to the file
    return file.path;
  }
  List<Widget> reservationsListScreen(ThisApplicationViewModel thisAppModel, int index) {
    List <Reservation> reservations = index == 0 ? thisAppModel.activeReservations : thisAppModel.pastReservations;
    return
      List.generate(reservations.length, (i) {
          Widget ticketContent = TicketContentWidget(
            index: i,
            reservation: reservations[i],
            isDialog: false,
          );
          return Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13.0),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 5.0.w, right: 5.0.w, top: 15.0.h, bottom: 10.0.h),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          PageRouteBuilder(
                              opaque : false,
                              barrierDismissible : true,
                              transitionDuration : const Duration(milliseconds: 300),
                              maintainState : true,
                              barrierColor : Colors.black54,
                              fullscreenDialog: false,
                              transitionsBuilder: (BuildContext context, anim1, anim2, Widget child) {
                                return FadeTransition(
                                    opacity: CurvedAnimation(
                                        parent: anim1,
                                        curve: Curves.easeOut
                                    ),
                                    child: child
                                );
                              },
                              pageBuilder: (BuildContext context, anim1, anim2) {
                                return ReservationDetails(
                                  index: i,
                                  ticketContent: TicketContentWidget(
                                    index: i,
                                    isDialog: true,
                                    reservation: reservations[i],
                                  )
                                );
                              }
                          )
                      );
                    },
                    child: ticketContent,
                  ),
                  Container(
                    height: 2,
                    width: 350.w,
                    color: AppTheme.veryLightGrey,
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          onPressed: (){
                            setState(() {
                              shareLoading=true;
                            });
                            _getQrCode("${reservations[i].ticketNumber}").then((path) {
                              setState(() {
                                shareLoading=false;
                              });
                              Share.shareXFiles(
                                  [XFile(path)],
                                  text: (translation(context)?.ticketDetails ?? "Ticket Details") + ' \n' +
                                      (translation(context)?.date ?? "Date") + ': ${reservations[i].trip?.plannedDate}\n' +
                                      (translation(context)?.time ?? "Time") + ': ${Tools.formatTime(reservations[i].plannedStartTime)}\n' +
                                      (translation(context)?.from ?? "From") + ': ${reservations[i].firstStop?.name}\n' +
                                      (translation(context)?.price ?? "Price") + ': ${Tools.formatPrice(thisAppModel, reservations[i].paidPrice!)}',
                                  subject: translation(context)?.ticketDetails ?? "Ticket Details");
                            });
                          },
                          child: Builder(
                            builder: (context) {
                              if(!shareLoading) {
                                return const Icon(
                                  Icons.share,
                                  color: AppTheme.darkPrimary,
                                  size: 25,
                                );
                              }
                              else {
                                return const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.darkPrimary,
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                            }
                          ),
                        ),
                        CupertinoButton(
                          onPressed: (){
                            //Navigate to TripTimelineScreen
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TripTimelineScreen(
                              tripID: reservations[i].trip?.id,
                              startStopID: reservations[i].firstStop?.id,
                              endStopID: reservations[i].endStopID,
                            )));
                          },
                          child: const Icon(
                            Icons.route_outlined,
                            color: AppTheme.darkPrimary,
                            size: 30,
                          ),
                        ),
                        //visible only when view active
                        if (index == 0) CupertinoButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TrackBusScreen(
                                            reservationId: reservations[i].id,
                                            channelId: reservations[i].trip!.channel!,
                                            startTime: Tools.formatTime(reservations[i].plannedStartTime),
                                            startDate: reservations[i].trip!.plannedDate!
                                        )
                                )
                            );
                          },
                          child: const Icon(
                            FontAwesomeIcons.mapMarkedAlt,
                            color: AppTheme.darkPrimary,
                            size: 25,
                          ),
                        ),
                        CupertinoButton(
                          onPressed: (){
                            thisAppModel.createComplaintLoadingState.setError(null);
                            //Show bottom sheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                  onWillPop: () async {
                                    if(MediaQuery.of(context).viewInsets.bottom != 0.0) {
                                      FocusScope.of(context).unfocus();
                                      return false;
                                    }
                                    return true;
                                  },
                                  child: Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: ComplaintScreen(thisAppModel, reservations[i].id),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(
                            FontAwesomeIcons.solidFlag,
                            color: AppTheme.colorSecondary,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          );
        });
  }

  @override
  Widget build(context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          return (widget.showBar != null && widget.showBar!) ?
          Scaffold(
              appBar: buildAppBar(context, 'My Trips'),
              body: displayAllReservations(thisAppModel)
          ):
          displayAllReservations(thisAppModel);
          //return displayAllReservations(thisAppModel);
        });
  }
}



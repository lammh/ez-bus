import 'dart:math';

import 'package:ezbus/gui/screens/set_location_on_map_screen.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';
import '../../model/place.dart';
import '../../utils/tools.dart';
import '../languages/language_constants.dart';
import 'choose_trip_screen.dart';

class SetStartEndTimeForTripScreen extends StatefulWidget {
  final Place? destinationPlace;
  final Place? startPlace;
  const SetStartEndTimeForTripScreen({super.key, this.destinationPlace, this.startPlace});

  @override
  SetStartEndTimeForTripScreenState createState() => SetStartEndTimeForTripScreenState();
}

class SetStartEndTimeForTripScreenState extends State<SetStartEndTimeForTripScreen> with TickerProviderStateMixin {

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  final List<Marker> _markers = [];

  Place? startPlace;
  Place? destinationPlace;
  GoogleMapController? mapController;


  late Animation _animation;
  late AnimationController _controller;
  late Tween _tween;

  double _angle = 0.0;
  double _sx = 0.0;
  double _sy = 0.0;
  double _ex = 0.0;
  double _ey = 0.0;
  final List<double> _xList = [];
  final List<double> _yList = [];

  bool _controllerInitialized = false;

  DateTime? selectedDate;

  bool loading = false;

  bool animationReady = true;

  bool _showAnimation = true;
  @override
  void dispose() {
    //check if the controller is attached to the tree
    if(_controllerInitialized) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(widget.destinationPlace!=null) {
      setState(() {
        destinationPlace = widget.destinationPlace;
        updateMarkers();
        destinationAddressController.text = destinationPlace!.address!;
      });
    }
    if(widget.startPlace!=null) {
      setState(() {
        startPlace = widget.startPlace;
        updateMarkers();
        startAddressController.text = startPlace!.address!;
      });
    }

    destinationAddressFocusNode.addListener(() async {
      if (destinationAddressFocusNode.hasFocus) {
        destinationAddressFocusNode.unfocus();
        setState(() {
          animationReady = false;
          //delete destination marker
          _markers.removeWhere((element) => element.markerId.value == "Destination");
        });
        final Place? result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SetLocationOnMapScreen(currentPlace: destinationPlace, action: "SetAddress")));

        if (result != null) {
          setState(() {
            destinationPlace = result;
            updateMarkers();
            destinationAddressController.text = result.address!;
            animationReady = true;
          });
        }
      }
    });

    startAddressFocusNode.addListener(() async {
      if (startAddressFocusNode.hasFocus) {
        startAddressFocusNode.unfocus();
        setState(() {
          animationReady = false;
          //delete start marker
          _markers.removeWhere((element) => element.markerId.value == "Start");
        });
        final Place? result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SetLocationOnMapScreen(currentPlace: startPlace,action: "SetAddress")));

        if (result != null) {
          setState(() {
            startPlace = result;
            updateMarkers();
            startAddressController.text = result.address!;
            animationReady = true;
          });
        }
      }
    });
  }
  LatLngBounds? getBoundsMarker(){
    if(mapController==null) {
      return null;
    }
    if(_markers.isEmpty || _markers.length==1){
      return null;
    }

    return Tools.createBounds(_markers.map((m) => m.position).toList());
  }


  // LatLngBounds? checkIfBothAddressesAreSet(Set<Marker> markers) {
  //   if(mapController==null) {
  //     return null;
  //   }
  //   if (startAddressController.text.isNotEmpty && destinationAddressController.text.isNotEmpty) {
  //     // _markers.add(createMarker('Start', startPlace!));
  //     // _markers.add(createMarker('Destination', destinationPlace!));
  //     //Define two position variables
  //     LatLng startLatLng = LatLng(
  //         startPlace!.latitude!, startPlace!.longitude!);
  //     LatLng destinationLatLng = LatLng(
  //         destinationPlace!.latitude!, destinationPlace!.longitude!);
  //     LatLngBounds bounds;
  //     if(startLatLng.latitude > destinationLatLng.latitude){
  //       bounds = LatLngBounds(
  //         northeast: startLatLng,
  //         southwest: destinationLatLng,
  //       );
  //     }
  //     else{
  //       bounds = LatLngBounds(
  //         northeast: destinationLatLng,
  //         southwest: startLatLng,
  //       );
  //     }
  //     LatLng centerBounds=LatLng(
  //         (bounds.northeast.latitude+bounds.southwest.latitude)/2,
  //         (bounds.northeast.longitude+bounds.southwest.longitude)/2
  //     );
  //     return bounds;
  //     //return zoomToFit(mapController!, bounds, centerBounds);
  //   }
  //   return null;
  // }
  // Future<void> zoomToFit(GoogleMapController controller, LatLngBounds bounds, LatLng centerBounds) async {
  //   bool keepZoomingOut = true;
  //   //Start off at max zoom level
  //   controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //     target: centerBounds,
  //     zoom: 100,
  //   )));
  //   while(keepZoomingOut) {
  //     final LatLngBounds screenBounds = await controller.getVisibleRegion();
  //     if(fits(bounds, screenBounds)){
  //       keepZoomingOut = false;
  //       final double zoomLevel = await controller.getZoomLevel() - 0.5;
  //       controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: centerBounds,
  //         zoom: zoomLevel,
  //       )));
  //       break;
  //     }
  //     else {
  //       // Zooming out by 0.1 zoom level per iteration
  //       final double zoomLevel = await controller.getZoomLevel() - 0.1;
  //       controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: centerBounds,
  //         zoom: zoomLevel,
  //       )));
  //     }
  //   }
  // }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    var const_ = 0.01;
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude + const_;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude + const_;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude + const_;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude + const_;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: buildAppBar(context, 'Set start and destination'),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.darkPrimary,
          onPressed: () {
            startSearch();
          },
          child: Text(
            translation(context)?.go ?? 'GO',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                (startAddressController.text.isNotEmpty ||
                    destinationAddressController.text.isNotEmpty)
                    ? googleMapsWidget()
                    : const SizedBox(height: 0),
              ],
            ),
            DirectionPositioned(
              top: 35.h,
              left: 20.w,
              right: 20.w,
              child: Stack(
                children: [
                  Container(
                    width: 350.w,
                    height: 189.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white,
                    ),
                  ),
                  DirectionPositioned(
                    top: 10.h,
                    left: 10.w,
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_outlined),
                    ),
                  ),
                  DirectionPositioned(
                    top: 60.h,
                    left: 30.w,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 19.83.w,
                          height: 19.89,
                          child: Stack(
                            children: [
                              DirectionPositioned(
                                left: 4.72.w,
                                top: 4.74.h,
                                child: Container(
                                  width: 10.39.w,
                                  height: 10.42,
                                  decoration: const ShapeDecoration(
                                    color: Color(0xFF34A853),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                              DirectionPositioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 19.83.w,
                                  height: 19.89,
                                  decoration: const ShapeDecoration(
                                    shape: OvalBorder(
                                      side: BorderSide(width: 1.5, color: Color(0xFF34A853)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3,),
                        SvgPicture.asset(
                          "assets/images/dashedLine.svg"
                        ),
                        SizedBox(height: 5.h,),
                        SvgPicture.asset(
                            "assets/images/locationIcon.svg"
                        ),
                      ],
                    ),
                  ),
                  DirectionPositioned(
                    top: 60.h,
                    left: 60.w,
                    child:Row(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                translation(context)?.start ?? 'START',
                                style: const TextStyle(
                                  color: Color(0xFFB9B9B9),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    animationReady = false;
                                    //delete start marker
                                    _markers.removeWhere((element) => element.markerId.value == "Start");
                                  });
                                  final Place? result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SetLocationOnMapScreen(currentPlace: startPlace,action: "SetAddress")));

                                  if (result != null) {
                                    setState(() {
                                      startPlace = result;
                                      updateMarkers();
                                      startAddressController.text = result.address!;
                                      animationReady = true;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 150.w,
                                      child: Text(
                                        startAddressController.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 15,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 75.w,),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF666666),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h,),
                              Container(
                                width: 230.w,
                                height: 1.h,
                                color: const Color(0xFFB9B9B9),
                              ),
                              SizedBox(height: 10.h,),
                              Text(
                                translation(context)?.destination ?? 'DESTINATION',
                                style: TextStyle(
                                  color: Color(0xFFB9B9B9),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  setState(() {
                                    animationReady = false;
                                    //delete destination marker
                                    _markers.removeWhere((element) => element.markerId.value == "Destination");
                                  });
                                  final Place? result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SetLocationOnMapScreen(currentPlace: destinationPlace, action: "SetAddress")));

                                  if (result != null) {
                                    setState(() {
                                      destinationPlace = result;
                                      updateMarkers();
                                      destinationAddressController.text = result.address!;
                                      animationReady = true;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 150.w,
                                      child: Text(
                                        destinationAddressController.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 15,
                                          fontFamily: 'Open Sans',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 75.w,),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF666666),
                                    )
                                  ],
                                ),
                              ),
                            ]
                        ),
                        SizedBox(width: 5.w,),
                        IconButton(onPressed: (){
                          Place tempPlace = startPlace!;
                          startPlace = destinationPlace;
                          destinationPlace = tempPlace;
                          setState(() {
                            _xList.clear();
                            _yList.clear();
                            animationReady = false;
                            _markers.clear();
                          });
                          // await Future.delayed(const Duration(milliseconds: 2000));
                          setState(() {
                            updateMarkers();
                            //switch the start and destination
                            String temp = startAddressController.text;
                            startAddressController.text =
                                destinationAddressController.text;
                            destinationAddressController.text = temp;
                            animationReady = true;
                          });
                        },
                        icon: const RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            FontAwesomeIcons.exchangeAlt,
                            color: Colors.black,
                          ),
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget googleMapsWidget()
  {
    final devicePixelRatio =
        MediaQuery.of(context).devicePixelRatio;
    // create a list of markers on google maps
    return Expanded(
      child: loading ? const Center(
        child: CircularProgressIndicator(),
      ) : Stack(
        children: [
          GoogleMap(
            markers: getMarkers(),
            // zoomGesturesEnabled: false,
            // scrollGesturesEnabled: false,
            // tiltGesturesEnabled: false,
            // rotateGesturesEnabled: false,
            // zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: getCenter(),
              zoom: 11.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              //adjustBounds();
            },
            onCameraMoveStarted: () {
              //stop animation
              if(_controllerInitialized){
                _controller.stop();
              }
              _xList.clear();
              _yList.clear();
              setState(() {
                _showAnimation = false;
              });
            },
            onCameraMove: (CameraPosition position) {
              if(_controllerInitialized){
                _controller.stop();
              }
              _xList.clear();
              _yList.clear();
            },
            onCameraIdle: () {
              if (startPlace == null || destinationPlace == null) {
                return;
              }
              ScreenCoordinate start, end;
              mapController?.getScreenCoordinate(
                  LatLng(startPlace!.latitude!, startPlace!.longitude!))
                  .then((s) {
                start = s;
                mapController?.getScreenCoordinate(
                    LatLng(destinationPlace!.latitude!,
                        destinationPlace!.longitude!)).then((ee) {
                  if(animationReady) {
                    end = ee;
                    _sx = start.x.toDouble() / devicePixelRatio;
                    _sy = start.y.toDouble() / devicePixelRatio;
                    _ex = end.x.toDouble() / devicePixelRatio;
                    _ey = end.y.toDouble() / devicePixelRatio;
                    if (_sx == _ex && _sy == _ey) {
                      return;
                    }
                    if (_sx < 0 || _sy < 0 || _ex < 0 || _ey < 0) {
                      return;
                    }

                    _xList.clear();
                    _yList.clear();

                    _xList.add(_sx);
                    _yList.add(_sy);
                    setState(() {
                      _showAnimation = true;
                    });
                    _createAnimation();
                  }
                });
              });
            },
          ),
          animationReady && _showAnimation? CustomPaint(
              painter: DrawLinePainter(
                  xList: _xList,
                  yList: _yList,
                  sx: _sx,
                  sy: _sy,
                  ex: _ex,
                  ey: _ey)): const SizedBox(),
        ],
      ),
    );
  }

  void _createAnimation() {
    _tween = Tween(begin: 3.14, end: 0);
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _controllerInitialized = true;
    _animation = _tween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          if (_animation.value is int) {
            _angle = _animation.value.toDouble();
          } else {
            _angle = _animation.value;
          }

          final s = (_sx + _ex) / 2;
          final t = (_sy + _ey) / 2;

          final A =
              sqrt(pow((_sx - _ex), 2) + pow((_sy - _ey), 2)) /
                  2;
          final B =
              sqrt(pow((_sx - _ex), 2) + pow((_sy - _ey), 2)) /
                  6;

          final COS = (_ex - _sx) /
              sqrt(pow((_sx - _ex), 2) + pow((_sy - _ey), 2));
          final SIN = (_ey - _sy) /
              sqrt(pow((_sx - _ex), 2) + pow((_sy - _ey), 2));

          final x = A * cos(_angle) * COS - B * sin(_angle) * SIN + s;
          final y = A * cos(_angle) * SIN + B * sin(_angle) * COS + t;

          _xList.add(x);
          _yList.add(y);
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _xList.clear();
          _yList.clear();
          _xList.add(_sx);
          _yList.add(_sy);
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();
  }

  getCenter() {
    if(startPlace == null && destinationPlace == null){
      return const LatLng(0, 0);
    }
    if(startPlace  != null && destinationPlace  == null){
      return LatLng(startPlace!.latitude!, startPlace!.longitude!);
    }
    if(startPlace  == null && destinationPlace  != null){
      return LatLng(destinationPlace!.latitude!, destinationPlace!.longitude!);
    }
    final centerLat = (startPlace!.latitude! + destinationPlace!.latitude!) / 2;
    final centerLng = (startPlace!.longitude! + destinationPlace!.longitude!) / 2;
    return LatLng(centerLat, centerLng);
  }

  Marker createMarker(String s, Place place) {
    return Marker(
      markerId: MarkerId(s),
      position: LatLng(place.latitude!, place.longitude!),
      infoWindow: InfoWindow(
        title: s,
        snippet: place.address,
      ),
      icon: BitmapDescriptor.defaultMarker,
      consumeTapEvents: true,
    );
  }

  startSearch() {
    //got to ChooseTripScreen with the start place and destination place
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseTripScreen(
          startPlace: startPlace,
          destinationPlace: destinationPlace,
          time: selectedDate == null ? DateTime.now() : selectedDate!,
        ), settings: const RouteSettings(name: 'ChooseTripScreen')
      ),
    );
  }

  void updateMarkers() {
    //await Future.delayed(const Duration(milliseconds: 500));
    if(destinationPlace != null) {
      if (_markers.isNotEmpty) {
        _markers.removeWhere((element) =>
        element.markerId.value == 'Destination');
      }
      _markers.add(createMarker('Destination', destinationPlace!));
    }

    if(startPlace != null) {
      if (_markers.isNotEmpty) {
        _markers.removeWhere((element) => element.markerId.value == 'Start');
      }
      _markers.add(createMarker('Start', startPlace!));
    }
    adjustBounds();
  }

  Future<void> adjustBounds() async {

    if(mapController == null) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if(mapController == null) {
        return;
      }
    }
    setState(() {
      LatLngBounds? boundss = getBoundsMarker();
      if(boundss != null) {
        mapController?.animateCamera(CameraUpdate.newLatLngBounds(boundss, 80));
      }
    });
  }

  Set<Marker> getMarkers() {
    //convert _markers to set
    Set<Marker> markers = {};
    for (var i = 0; i < _markers.length; i++) {
      markers.add(_markers[i]);
    }
    return markers;

  }
}

class DrawLinePainter extends CustomPainter {
  final List<double> xList;
  final List<double> yList;
  final double sx;
  final double sy;
  final double ex;
  final double ey;
  DrawLinePainter(
      {required this.xList,
        required this.yList,
        required this.sx,
        required this.sy,
        required this.ex,
        required this.ey});

  @override
  void paint(Canvas canvas, Size size) {
    if (xList.isNotEmpty) {
      final Paint line = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      for (var i = 0; i < xList.length - 1; i++) {
        canvas.drawLine(Offset(xList[i], yList[i]),
            Offset(xList[i + 1], yList[i + 1]), line);
      }

      final Paint line2 = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.fill
        ..strokeWidth = 3.0;
      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), line2);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
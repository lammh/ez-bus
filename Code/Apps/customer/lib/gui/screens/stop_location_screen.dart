import 'dart:async';
import 'dart:math';

import 'package:ezbus/model/route_direction.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:ezbus/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../model/constant.dart';
import '../../model/stop.dart';
import '../../utils/tools.dart';
import '../widgets/app_bar.dart';

class StopLocationScreen extends StatefulWidget {
  final Stop? stop;
  const StopLocationScreen({Key? key, this.stop}) : super(key: key);

  @override
  StopLocationScreenState createState() => StopLocationScreenState();
}
class StopLocationScreenState extends State<StopLocationScreen> {
  Completer<GoogleMapController>? mapController = Completer();
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  Marker? marker;

  @override
  void initState() {
    marker = createMarker(widget.stop!);
    super.initState();
  }
  Widget displayStopMap() {
    bool isMapAdjusted = false;
    //Get the bounds from markers
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(double.parse(widget.stop!.lat!), double.parse(widget.stop!.lng!)),
        zoom: 15,
      ),
      markers: getMarkers(),
      onMapCreated: (GoogleMapController controller) async {
        mapController?.complete(controller);
      },
    );
  }

  Marker createMarker(Stop stop) {
    return Marker(
      markerId: MarkerId(stop.name!),
      position: LatLng(
          double.parse(stop.lat!), double.parse(stop.lng!)),
      infoWindow: InfoWindow(
        title: stop.name!,
        snippet: stop.address,
      ),
      icon: BitmapDescriptor.defaultMarker,
      // consumeTapEvents: true,
    );
  }

  Set<Marker> getMarkers() {
    //convert _markers to set
    Set<Marker> markers_ = {};
    markers_.add(marker!);
    return markers_;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, widget.stop!.name!),
      body: Consumer<ThisApplicationViewModel>(
          builder: (context, thisAppModel, child) {
            return displayStopMap();
          }),
    );
  }

  calculateCenterPoint(List<Marker> markers) {
    double x = 0;
    double y = 0;
    double z = 0;
    for (var i = 0; i < markers.length; i++) {
      double latitude = markers.elementAt(i).position.latitude * pi / 180;
      double longitude = markers.elementAt(i).position.longitude * pi / 180;
      x += cos(latitude) * cos(longitude);
      y += cos(latitude) * sin(longitude);
      z += sin(latitude);
    }
    double total = markers.length.toDouble();
    x = x / total;
    y = y / total;
    z = z / total;
    double centralLongitude = atan2(y, x);
    double centralSquareRoot = sqrt(x * x + y * y);
    double centralLatitude = atan2(z, centralSquareRoot);
    return LatLng(centralLatitude * 180 / pi, centralLongitude * 180 / pi);
  }
}

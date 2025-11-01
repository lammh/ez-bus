import 'package:ezbus/gui/screens/set_start_end_time_for_trip_screen.dart';
import 'package:ezbus/model/reservation.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';

import '../../model/place.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentTripWidget extends StatefulWidget {
  final Reservation? reservation;
  const RecentTripWidget( {super.key, this.reservation});

  @override
  State<StatefulWidget> createState() => SpecialPostCard();
}

class SpecialPostCard extends State<RecentTripWidget> {

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  @override
  Widget build(BuildContext context) {
    return displaySingleReservation(widget.reservation);
  }



  getIconType(int type)
  {
    switch(type)
    {
      case 1:
        return SizedBox(
          width: 50.w,
            child: Image.asset("assets/icons/home.png")
        );
      case 2:
        return SizedBox(
            width: 50.w,
            child: Image.asset("assets/icons/work.png")
        );
      default:
        return SizedBox(
            width: 50.w,
            child: Image.asset("assets/icons/location.png")
        );
    }
  }

  Widget displaySingleReservation(Reservation? reservation) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return InkWell(
      child: Container(
        width: width / 2,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(25),
          //shadow
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  child:
                  getIconType(0),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0,8,10,8),
                child: Text(
                    reservation!.firstStop!.name!,
                    style: AppTheme.subtitle,
                    overflow: reservation.firstStop!.name!.length> 20 ? TextOverflow.ellipsis: null
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(reservation.firstStop!.address == null? "" : reservation.firstStop!.address!,
                  style: AppTheme.subtitle2,
                  overflow: reservation.firstStop!.address != null && reservation.firstStop!.address!.length> 20 ? TextOverflow.ellipsis: null),
            ),
          ],
        ),
      ),
      onTap: () {
        Place? startPlace, endPlace;
        startPlace = Place(
            address: reservation.startAddress,
            latitude: double.parse(reservation.firstStop!.lat!),
            longitude: double.parse(reservation.firstStop!.lng!));

        endPlace = Place(
            address: reservation.destinationAddress,
            latitude: reservation.endPointLatitude!,
            longitude: reservation.endPointLongitude!);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SetStartEndTimeForTripScreen(destinationPlace: endPlace, startPlace: startPlace,)),
        );
      },
    );
  }
}

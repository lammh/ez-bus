
import 'package:ezbus/gui/screens/set_start_end_time_for_trip_screen.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../model/place.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../screens/set_location_on_map_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoritePlaceWidget extends StatefulWidget {
  final Place? place;
  final Position? gpsLocation;
  const FavoritePlaceWidget( {super.key, this.place, this.gpsLocation});

  @override
  State<StatefulWidget> createState() => SpecialPostCard();
}

class SpecialPostCard extends State<FavoritePlaceWidget> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  bool finished = false;
  bool pressedDown = false;
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 4, end: 0).animate(_controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //return displaySinglePost(widget.place, widget.gpsLocation);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            _controller.forward().whenComplete((){
                pressedDown = true;
            });
          },
          onTapUp: (_) {
            if(!pressedDown) {
              _controller.forward(from: 4).whenComplete(() {
                pressedDown = false;
                finished = true;
                _controller.reverse().whenComplete(() {
                  Place? startPlace;
                  if (widget.gpsLocation != null) {
                    startPlace = Place(
                        address: translation(context)?.currentLocation ?? "Current location",
                        latitude: widget.gpsLocation!
                            .latitude,
                        longitude: widget.gpsLocation!
                            .longitude);
                  }
                  if (thisAppModel.isLoggedIn == true) {
                    if (widget.place!.longitude == 0 &&
                        widget.place!.latitude == 0) {
                      showPlaceNotSetDialog(context, widget.place);
                    }
                    else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            SetStartEndTimeForTripScreen(
                              destinationPlace: widget.place,
                              startPlace: startPlace,)),
                      ).then((value) {
                        finished = false;
                        pressedDown = false;
                      });
                    }
                  }
                  else {
                    showLoginDialog(context, widget);
                  }
                });
              });
            }
            if(!finished){
              finished = true;
              _controller.reverse().whenComplete(() {
                Place? startPlace;
                if (widget.gpsLocation != null) {
                  startPlace = Place(
                      address: translation(context)?.currentLocation ?? "Current location",
                      latitude: widget.gpsLocation!
                          .latitude,
                      longitude: widget.gpsLocation!
                          .longitude);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetStartEndTimeForTripScreen(destinationPlace: widget.place, startPlace: startPlace,)),
                ).then((value) {
                  finished = false;
                  pressedDown = false;
                });
              });
            }
          },
          onTapCancel: (){
            if(!pressedDown){
              _controller.forward(from: 4).whenComplete((){
                pressedDown = false;
                finished = true;
                _controller.reverse().whenComplete(() {
                  finished = false;
                  pressedDown = false;
                });
              });
            }
            if(!finished){
              finished = true;
              _controller.reverse().whenComplete(() {
                finished = false;
                pressedDown = false;
              });
            }
          },
          onLongPress: (){
            HapticFeedback.vibrate();
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: widget.place?.type == 0? 150: 100,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text("Edit"),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SetLocationOnMapScreen(currentPlace: widget.place, action: "EditPlace",)),
                            );
                          },
                        ),
                        widget.place?.type == 0? ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text("Delete"),
                          onTap: () {
                            Navigator.pop(context);
                            showConfirmDeleteDialog(context, widget.place).then((value) {
                              if(value == true)
                              {
                                thisAppModel.deletePlaceEndpoint(widget.place!.id!, true, null);
                              }
                            });
                          },
                        ):Container(),
                      ],
                    ),
                  );
                });
          },
          child: SizedBox(
            width: 110.h,
            child: Container(
              margin: EdgeInsets.only(
                bottom: 2.h,
              ),
              padding: EdgeInsets.only(
                left: 6.w,
                top: 9.h,
                right: 6.w,
                bottom: 9.h,
              ),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  16,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 2.w,
                    blurRadius: 2.w,
                    offset: Offset(
                      0,
                      _animation.value,
                    ),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 1.h,
                          ),
                          child: Image.asset(
                            widget.place!.type == 1? "assets/icons/home.png": widget.place!.type == 2? "assets/icons/work.png": "assets/icons/locationMarker.png",
                            width: 25.w,
                            height: 25.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 6.h,
                    ),
                    child: Text(
                      widget.place!.name!,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppTheme.textDarkBlueLarge,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      bottom: 1.h,
                    ),
                    child: Text(
                      widget.place!.address?? "",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: const Color(0XFF3F3F3F).withOpacity(0.65),
                        fontSize: 10,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget displaySinglePost(Place? item, Position? gpsLocation) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    //get index of item
    int? index = thisAppModel.favoritePlaces?.indexOf(item!);
    if(index!=null) {
      if (thisAppModel.deleteFavoritePlacesLoadingStates[index].inLoading() == true) {
        return Container(
          width: width / 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }
    return placeCard(item, width, gpsLocation);
  }

  //are you sure dialog for delete
  Future showConfirmDeleteDialog(BuildContext context, Place? item) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you want to delete this place?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(translation(context)?.no ?? "No"),
              ),
              TextButton(
                onPressed: () {
                  //delete
                  Navigator.pop(context, true);
                },
                child: Text(translation(context)?.yes ?? "Yes"),
              ),
            ],
          );
        });
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
        return Image.asset("assets/icons/location.png");
    }
  }

  Widget placeCard(Place? item, double width, Position? gpsLocation) {
    return InkWell(
      child: Container(
        width: width / 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: const Icon(
                      Icons.more_vert_outlined,
                      size: 25,
                      color: Color(0xFF5F6368),
                    ),
                    onTap: () {
                      //show bottom sheet for edit and delete
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: item?.type == 0? 150: 100,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text("Edit"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SetLocationOnMapScreen(currentPlace: item, action: "EditPlace",)),
                                      );
                                    },
                                  ),
                                  item?.type == 0? ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text("Delete"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showConfirmDeleteDialog(context, item).then((value) {
                                        if(value == true)
                                        {
                                          thisAppModel.deletePlaceEndpoint(item!.id!, true, null);
                                        }
                                      });
                                    },
                                  ):Container(),
                                ],
                              ),
                            );
                          });
                    },
                  ),
                )
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  child:
                  getIconType(item!.type),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0,8,10,8),
                child: Text(
                    item.name!,
                    style: AppTheme.subtitle,
                    overflow: item.name!.length> 20 ? TextOverflow.ellipsis: null
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item.address == null? "" : item.address!,
                  style: AppTheme.subtitle2,
                  overflow: item.address != null && item.address!.length> 20 ? TextOverflow.ellipsis: null),
            ),
          ],
        ),
      ),
      onTap: () {
        Place? startPlace;
        if (gpsLocation != null) {
          startPlace = Place(
              address: translation(context)?.currentLocation ?? "Current location",
              latitude: gpsLocation
                  .latitude,
              longitude: gpsLocation
                  .longitude);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SetStartEndTimeForTripScreen(destinationPlace: item, startPlace: startPlace,)),
        );
      },
    );
  }
}

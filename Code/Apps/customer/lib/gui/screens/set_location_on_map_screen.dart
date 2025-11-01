import 'package:ezbus/gui/screens/favorite_places_screen.dart';
import 'package:ezbus/gui/screens/recent_places_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';
import '../../connection/utils.dart';
import '../../model/place.dart';
import '../../services/service_locator.dart';
import '../../utils/config.dart';
import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';
import '../widgets/google_map_with_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetLocationOnMapOptions {
  final bool? showHistoryButton;
  final bool? showFavoriteButton;
  final String? title;
  final String? saveButtonText;
  final String? saveButtonAction;

  SetLocationOnMapOptions({
    this.showHistoryButton,
    this.showFavoriteButton,
    this.title,
    this.saveButtonText,
    this.saveButtonAction,
  });

  addNewFavoritePlaceOptions(BuildContext context) {
    return SetLocationOnMapOptions(
      showHistoryButton: true,
      showFavoriteButton: false,
      title: translation(context)?.addFavoritePlace ?? "Add Favorite Place",
      saveButtonText: translation(context)?.ok ?? "OK",
      saveButtonAction: "addNewFavoritePlace",
    );
  }

  editFavoritePlaceOptions(BuildContext context) {
    return SetLocationOnMapOptions(
      showHistoryButton: true,
      showFavoriteButton: false,
      title: translation(context)?.editPlace ?? "Edit Place",
      saveButtonText: translation(context)?.ok ?? "OK",
      saveButtonAction: "editFavoritePlace",
    );
  }

  setAddressOptions(BuildContext context) {
    return SetLocationOnMapOptions(
      showHistoryButton: true,
      showFavoriteButton: true,
      title: translation(context)?.setAddress ?? "Set Address",
      saveButtonText: translation(context)?.ok ?? "OK",
      saveButtonAction: "getAddress",
    );
  }
}

class SetLocationOnMapScreen extends StatefulWidget {

  final Place? currentPlace;
  final String? action;

  const SetLocationOnMapScreen({Key? key, this.currentPlace, this.action}) : super(key: key);

  @override
  SetLocationOnMapScreenState createState() => SetLocationOnMapScreenState(currentPlace: currentPlace, action: action);
}

class SetLocationOnMapScreenState extends State<SetLocationOnMapScreen> {
  String? currentAddress;
  LatLng? currentLatLng;

  bool? acquiringLocation;


  SetLocationOnMapScreenState({this.currentPlace, this.action});

  SetLocationOnMapOptions? options;
  String? action;

  Place? currentPlace;

  Place? place;
  bool? showSaveButton = true;
  bool? showHistoryButton = true;
  final _nameTextFieldController = TextEditingController();

  ThisApplicationViewModel? thisAppModel = serviceLocator<ThisApplicationViewModel>();
  @override
  void initState() {
    if (currentPlace != null) {
      if(currentPlace!.latitude != null &&
      currentPlace!.longitude != null) {
        currentLatLng = LatLng(
            currentPlace!.latitude as double,
            currentPlace!.longitude as double);
        thisAppModel!.mapData?.currentLatLng = currentLatLng!;
      }
      if(currentPlace!.address != null) {
        currentAddress = currentPlace!.address!;
        thisAppModel!.mapData?.currentAddress = currentAddress!;
      }
      if(currentPlace!.name != null) {
        _nameTextFieldController.text = currentPlace!.name!;
      }
      place = currentPlace!;
    } else {
      place = Place();
    }
    super.initState();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if(action == "AddFavoritePlace") {
      options = SetLocationOnMapOptions().addNewFavoritePlaceOptions(context);
    } else if(action == "EditPlace") {
      options = SetLocationOnMapOptions().editFavoritePlaceOptions(context);
    } else if(action == "SetAddress") {
      options = SetLocationOnMapOptions().setAddressOptions(context);
    } else {
      options = SetLocationOnMapOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          return Scaffold(
              // appBar: buildAppBar(context,
              //     options!.title!),
              body: Stack(
                  children: [
                    GoogleMapWithIcon(currentLatLng: currentLatLng, currentAddress: currentAddress),
                    DirectionPositioned(
                        top: 35.h,
                        left: 10.w,
                        right: 10.w,
                        child: Card(
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20)
                            ),
                          ),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0.w, bottom: 5.0.h),
                                  child: IconButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.arrow_back_outlined)
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: InkWell(
                                    onTap: () async {
                                      var prediction = await PlacesAutocomplete
                                          .show(
                                        context: context,
                                        apiKey: Config.googleApikey,
                                        mode: Mode.overlay,
                                        types: [],
                                        strictbounds: false,
                                        components: [],
                                        //google_map_webservice package
                                        onError: (err) {
                                          if (kDebugMode) {
                                            print(err);
                                          }
                                        },
                                      );

                                      if (prediction != null) {
                                        setState(() {
                                          setState(() {
                                            thisAppModel.mapData?.currentAddress =
                                                prediction.description.toString();
                                          });
                                        });
                                        //form google_maps_webservice package
                                        final plist = GoogleMapsPlaces(
                                          apiKey: Config.googleApikey,
                                          apiHeaders: await const GoogleApiHeaders()
                                              .getHeaders(),
                                          //from google_api_headers package
                                        );
                                        String placeId = prediction.placeId ??
                                            "0";
                                        final detail = await plist
                                            .getDetailsByPlaceId(placeId);
                                        final geometry = detail.result
                                            .geometry;
                                        final double? lat = geometry?.location.lat;
                                        final double? lang = geometry?.location.lng;
                                        setState(() {
                                          thisAppModel.mapData?.currentLatLng =
                                              LatLng(lat!, lang!);
                                        });

                                        if (kDebugMode) {
                                          print(
                                              thisAppModel.mapData?.currentLatLng!);
                                        }
                                        //move map camera to selected place with animation
                                        thisAppModel.mapController?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                    target: thisAppModel.mapData!
                                                        .currentLatLng!,
                                                    zoom: 17)));
                                      }
                                    },
                                    child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 0.7, color: Colors.grey),
                                      )),
                                      child: ListTile(
                                        title: Text(thisAppModel.mapData?.currentAddress ?? "Search Address",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontFamily: 'Open Sans',
                                            color: AppTheme.lightGrey,
                                          ),),
                                        trailing: const Icon(FontAwesomeIcons.search, size: 20, weight: 0.1,),
                                        dense: true,
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                    DirectionPositioned(
                      right: 10.w,
                      top: 175.h,
                      child: Column(
                        children: [
                          options!.showHistoryButton! ? TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              alignment: Alignment.center,
                              elevation: 7,
                              shape: const CircleBorder(),
                            ),
                            child: SizedBox(
                              width: 40.w,
                              height: 40.h,
                              child: const Icon(
                                Icons.history,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RecentPlacesScreen()),
                              );
                              if (result != null) {
                                setState(() {
                                  thisAppModel.mapData?.currentLatLng =
                                      LatLng(result.latitude, result.longitude);
                                  thisAppModel.mapData?.currentAddress = result.address;
                                });
                                thisAppModel.mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: thisAppModel.mapData!
                                                .currentLatLng!,
                                            zoom: 17)));
                              }
                            },
                          ) : Container(),
                          SizedBox(height: 20.h,),
                          options!.showFavoriteButton! ? TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              alignment: Alignment.center,
                              elevation: 7, //Defines Elevation
                              shape: const CircleBorder(),
                            ),
                            child: SizedBox(
                              width: 40.w,
                              height: 40.h,
                              child: const Icon(
                                Icons.favorite_border_outlined,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoritePlacesScreen()),
                              );
                              if (result != null) {
                                setState(() {
                                  thisAppModel.mapData?.currentLatLng =
                                      LatLng(result.latitude, result.longitude);
                                  thisAppModel.mapData?.currentAddress = result.address;
                                });
                                thisAppModel.mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: thisAppModel.mapData!
                                                .currentLatLng!,
                                            zoom: 17)));
                              }
                            },
                          ) : Container(),
                          SizedBox(
                            height: 20.h,
                          ),
                          ClipOval(
                            child: Material(
                              color: Colors.orange.shade100, // button color
                              child: InkWell(
                                splashColor: Colors.orange, // inkwell color
                                child: SizedBox(
                                  width: 56.w,
                                  height: 56,
                                  child: const Icon(Icons.my_location),
                                ),
                                onTap: () {
                                  setState(() {
                                    acquiringLocation = true;
                                  });
                                  checkLocationService(context).then((LocationServicesStatus value) {
                                    showToast(value);
                                    if (value != LocationServicesStatus.enabled) {
                                      setState(() {
                                        acquiringLocation = false;
                                      });
                                    }
                                    else {
                                      getLocation()
                                          .then((value) {
                                        setState(() {
                                          acquiringLocation = false;
                                          Position position = value;
                                          thisAppModel.mapData!
                                              .currentLatLng = LatLng(
                                              position.latitude,
                                              position.longitude);
                                          thisAppModel.mapData!.currentAddress =
                                          "Current Location";
                                        });
                                        thisAppModel.mapController
                                            ?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                    target: thisAppModel
                                                        .mapData!
                                                        .currentLatLng!,
                                                    zoom: 17)));
                                      });
                                    }
                                  });

                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: acquiringLocation!=null && acquiringLocation! ? const CircularProgressIndicator() : Container(),
                    ),
                    //save place button at the bottom
                    DirectionPositioned(
                        bottom: 10.h,
                        left: 120.w,
                        right: 120.w,
                        child: InkWell(
                          onTap: () {
                           if (thisAppModel.mapData?.currentLatLng == null) {
                              return;
                            }
                            place!.name =
                            place!.type == 1 ? "Home" : place!.type == 2
                                ? "Work"
                                : "New Place";
                            place!.address = thisAppModel.mapData?.currentAddress;
                            place!.latitude = thisAppModel.mapData?.currentLatLng?.latitude;
                            place!.longitude = thisAppModel.mapData?.currentLatLng?.longitude;
                            if (action == "AddFavoritePlace" ||
                                action == "EditPlace") {
                              place!.favorite = 1;
                            }
                            else {
                              place!.favorite = 0;
                            }

                           if(action == "SetAddress") {
                             //return place to previous screen
                             Navigator.pop(context, place);
                           }
                           else {
                             if (place!.type != 1 && place!.type != 2) {
                               //hide save button
                               setState(() {
                                 if ((action == "AddFavoritePlace") ||
                                     (action == "EditPlace")) {
                                   showSaveButton = false;
                                 }
                               });

                               //show dialog to get place name
                               _showTextInputDialog(context).then((value) {
                                 if (value != null) {
                                   place!.name =
                                   value.isEmpty ? "New Place" : value;
                                   //save place to database
                                   thisAppModel.addPlaceEndpoint(
                                       place!, context);
                                 }
                               }).whenComplete(() {
                                 //show save button
                                 setState(() {
                                   showSaveButton = true;
                                 });
                               });
                             }
                             else {
                               //save place to database
                               thisAppModel.addPlaceEndpoint(place!, context);
                             }
                           }

                          },
                          child: showSaveButton! ? Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: thisAppModel.mapData?.currentLatLng == null
                                    ? Colors.grey
                                    : AppTheme.darkPrimary,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Center(
                              child: thisAppModel.createPlaceLoadingState
                                  .inLoading() ?
                              const CircularProgressIndicator(
                                color: Colors.white,) :
                              Text(options!.saveButtonText!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),),
                            ),
                          ) : Container(),
                        )
                    )
                  ]
              )
          );
        });
  }

  Future<String?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(translation(context)?.savePlace ?? 'Save Place'),
            content: TextField(
              controller: _nameTextFieldController,
              autofocus: true,
              decoration: InputDecoration(hintText: translation(context)?.newPlace ?? "New Place"),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(translation(context)?.cancel ?? "CANCEL"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(translation(context)?.save ?? 'SAVE'),
                onPressed: () =>
                    Navigator.pop(context, _nameTextFieldController.text),
              ),
            ],
          );
        });
  }

  void showToast(LocationServicesStatus value) {
    String text = "";
    if(value == LocationServicesStatus.disabled) {
      text = "Location service is disabled";
    }
    else if (value == LocationServicesStatus.denied) {
      text = "Location permission is denied";
    }
    else if (value == LocationServicesStatus.deniedForever) {
      text = "Location permission is permanently denied";
    }
    else if (value == LocationServicesStatus.disabled) {
      text = "Location service is disabled";
    }
    else {
      return;
    }
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        textColor: Colors.red,
        fontSize: 16.0
    );
  }
}
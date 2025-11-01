
import 'package:ezbus/model/place.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/gui/widgets/form_error.dart';
import 'package:ezbus/gui/widgets/app_bar.dart';
import 'package:ezbus/model/constant.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/tools.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';

import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/shimmers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';
class RecentPlacesScreen extends StatefulWidget {
  const RecentPlacesScreen({Key? key}) : super(key: key);

  @override
  RecentPlacesScreenState createState() => RecentPlacesScreenState();
}

class RecentPlacesScreenState extends State<RecentPlacesScreen> {
  ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

  final List<String> errors = [];

  void removeAllErrors() {
    setState(() {
      errors.clear();
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        thisAppModel.getRecentPlacesEndpoint();
      });
    });
  }

  Widget displayAllRecentPlaces() {
    return Scaffold(
      appBar: buildAppBar(context, translation(context)?.recentPlaces ?? 'Recent Places'),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              return displayRecentPlaces(context)!;
            },
          )),
    );
  }

  Widget? displayRecentPlaces(BuildContext context) {
    if (thisAppModel.recentPlacesLoadingState.inLoading()) {
      // loading. display animation
      Shimmers shimmer = Shimmers(
        options: ShimmerOptions().vListOptions(2),
      );
      return shimmer;
    } else if (thisAppModel.recentPlacesLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.recentPlacesLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context, thisAppModel.recentPlacesLoadingState.failState!);
      } else {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            List<Place> allRecentPlaces;
            allRecentPlaces = thisAppModel.recentPlaces!;
            if (allRecentPlaces.isEmpty) {
              return emptyScreen();
            } else {
              for (int i = 0;
                  i < thisApplicationViewModel.deleteRecentPlacesLoadingStates.length;
                  i++) {
                if (thisApplicationViewModel
                        .deleteRecentPlacesLoadingStates[i].loadError ==
                    1) {
                  errors.add(
                      thisApplicationViewModel.deleteRecentPlacesLoadingStates[i].error!);
                }
              }

              List<Widget> a = [];
              a.add(FormError(errors: errors));
              a.addAll(recentPlacesListScreen(allRecentPlaces, thisApplicationViewModel));
              return ListView(children: a);
            }
          },
        );
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
              "assets/images/img_no_place.png",
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 150
                      : 250,
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.h),
              child: Column(
                children: [
                  Text(
                    translation(context)?.noRecentPlacesYet ?? "Oops... There aren't any recent places yet.",
                    style: AppTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  List<Widget> recentPlacesListScreen(List<Place> allRecentPlaces,
      ThisApplicationViewModel thisApplicationViewModel) {
    return List.generate(allRecentPlaces.length, (i) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            child: ListTile(
                title: Text(
                  allRecentPlaces[i].address!,
                  style: AppTheme.bold14Grey60,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (translation(context)?.lastActive ?? 'Last active ') + (allRecentPlaces[i].lastUsedAt ?? ''),
                        style: AppTheme.coloredSubtitle,
                      ),
                    ],
                  ),
                ),
                leading: const Icon(
                  Icons.location_on_outlined,
                  size: 30,
                  color: Colors.grey,
                ),
                trailing: allRecentPlaces[i].type == 0 ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    thisApplicationViewModel.deleteRecentPlacesLoadingStates[i]
                        .inLoading()
                        ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red),
                    )
                        : IconButton(
                      icon: const Icon(
                        Icons.delete_outlined,
                        color: AppTheme.colorSecondary,
                      ),
                      onPressed: () {
                        showAlertDialog(
                            context,
                            thisApplicationViewModel,
                            allRecentPlaces[i].id);
                      },
                    )
                  ],
                ) : null,
                onTap: () {
                  Navigator.pop(context, allRecentPlaces[i]);
                }
            )),
      );
    });
  }

  showAlertDialog(
      BuildContext context,
      ThisApplicationViewModel thisApplicationViewModel,
      int? id) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(translation(context)?.cancel ?? "Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(translation(context)?.continueText ?? "Continue"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();

        removeAllErrors();
        thisApplicationViewModel.deletePlaceEndpoint(id!, false, null);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(translation(context)?.warning ?? "Warning"),
      content: Text(translation(context)?.areYouSureDeletePlace ?? "Are you sure to delete this place?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(context) {
    return displayAllRecentPlaces();
  }



  Widget loadingRecentPlaces() {
    return Center(
      child: SizedBox(
        width: 30.w,
        height: 30.h,
        child: const CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }
}

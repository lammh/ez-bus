
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbusdriver/gui/widgets/form_error.dart';
import 'package:ezbusdriver/model/my_notification.dart';
import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/utils/tools.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../connection/utils.dart';
import '../../model/push_notification.dart';
import '../../widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';
import 'package:ezbusdriver/gui/widgets/direction_positioned.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = false;
  bool markAllAsRead = false;
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.markNotificationSeenLoadingState.loadError = null;
          thisAppModel.markAllAsSeenNotificationsLoadingState.loadError = null;
          thisAppModel.getNotificationsEndpoint();
        }
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisAppModel.markNotificationSeenLoadingState.loadError = null;
      thisAppModel.markAllAsSeenNotificationsLoadingState.loadError = null;
      thisAppModel.getNotificationsEndpoint();
    });
  }


  Widget displayAllNotifications() {
    return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: displayNotifications(context)
          ),
        )
    );
  }

  Widget? displayNotifications(BuildContext context) {
    if (thisAppModel.notificationsLoadingState.inLoading()) {
      // loading. display animation
      return loadingNotifications();
    }
    else if (thisAppModel.notificationsLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.notificationsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisAppModel.notificationsLoadingState.failState!);
      }
      else {
        List<MyNotification> allNotifications;
        allNotifications = thisAppModel.notificationsList;
        if (allNotifications.isEmpty) {
          return
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/img_no_notifications.png", height: MediaQuery
                        .of(context)
                        .orientation == Orientation.landscape ? 50 : 200,),
                    Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: Column(
                        children: [
                          Text(translation(context)?.anyNotificationsYet ??
                              "Oops... There aren't any notifications yet.",
                            style: AppTheme.caption,
                            textAlign: TextAlign.center,),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
        else {
          List<Widget> a = [];
          a.addAll(notificationsListScreen(allNotifications));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: thisAppModel.unseenNotificationsCount > 0 ?
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: markAllButton(
                      thisAppModel.unseenNotificationsCount == 0
                          ? translation(context)?.markAllAsRead ??
                          "Mark all as read"
                          :
                      (translation(context)?.markAllAsRead ??
                          "Mark all as read") + " (" +
                          (thisAppModel.unseenNotificationsCount).toString() + ")",
                      context),
                ) : Container(),
              ),
              errorSection(),
              Expanded(
                child: ListView(
                    children: a
                ),
              ),
            ],
          );
        }
      }
    }
    return null;
  }


  Widget markAllButton(String text, BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
                child:
                markAllReadButton(text)
            ),
          ],
        ),
      ),
      onTap: ()
      {
        showAlertDialog(context, thisAppModel);
      },
    );
  }

  Widget failedScreen(BuildContext context, FailState failState) {
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
            Container(
              constraints: BoxConstraints(
                minHeight: Tools.getScreenHeight(context) - 150,
              ),
              child: Center(
                child: onFailRequest(context, failState),
              ),
            )
          ]
      );
  }

  Widget emptyScreen() {
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
                  Image.asset("assets/images/img_no_connected_dev.png", height: MediaQuery
                      .of(context)
                      .orientation == Orientation.landscape ? 50 : 150,),
                  Padding(
                    padding: EdgeInsets.only(top: 30.h),
                    child: Column(
                      children: [
                        Text("Oops... There aren't any notifications yet.",
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

  List<Widget> notificationsListScreen(List<MyNotification> allNotification) {
    return
      List.generate(allNotification
          .length, (i) {
        return InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DescriptionTextWidget(allNotification[i].message!),
                                  ),
                                ),
                              ],
                            ),
                            actionsSection(allNotification[i], i),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (allNotification[i].seen == 0) {
              thisAppModel.markNotificationEndpoint(
                  i, allNotification[i].id!);
            }
            //show notification details
            //create PushNotification object
            PushNotification notification = PushNotification();
            notification.title = "Alert";
            notification.body = allNotification[i].message;
            showNotificationDialog(context, notification);
          },
        );
      });
  }

  Widget actionsSection(MyNotification notification, int idx) {
    TextStyle style = AppTheme.textGreySmall;
    if(notification.seen == 0) {
      style = AppTheme.textPrimarySmallBold;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(notification.createdAt!, style: style,),
        ),
        notification.seen == 0 ?
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ): Container()
      ],
    );
  }

  Widget errorSection() {
    if (thisAppModel.markNotificationSeenLoadingState.loadError == 1) {
      return FormError(errors: [
        thisAppModel
            .markNotificationSeenLoadingState.error ?? ""
      ]);
    } else {
      return Container();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        if (thisApplicationViewModel.isLoggedIn!) {
          return displayAllNotifications();
        }
        else {
          return signInOut(context, null);
        }
      },
    );
  }

  Widget loadingNotifications() {
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

  Widget markAllReadButton(String text) {
    bool loading = false;
    if ((thisAppModel.notificationsList.isNotEmpty))
    {
      if (thisAppModel.markAllAsSeenNotificationsLoadingState.inLoading()) {
        loading = true;
      }
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: loading ?
            SizedBox(
              height: 25, width: 25.w,
              child: const CircularProgressIndicator(
                strokeWidth: 1,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkGrey),
              ),
            ) :
            const Icon(Icons.playlist_add_check_rounded, size: 25,),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      );
    }
    else {
      return Container();
    }
  }

  showAlertDialog(BuildContext context,
      ThisApplicationViewModel thisApplicationViewModel) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(translation(context)?.cancel ?? "Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(translation(context)?.continueText ?? "Continue"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop();
        //removeAllErrors();

        thisApplicationViewModel.markAllNotificationsAsReadEndpoint();

      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(translation(context)?.markAllNotificationsAsSeen ?? "Mark all notifications as seen"),
      content: Text(translation(context)?.markAllNotificationsAsSeen ?? "Mark all notifications as seen"),
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


}

class DescriptionTextWidget extends StatefulWidget {
  final String text;

  const DescriptionTextWidget(this.text, {super.key});

  @override
  DescriptionTextWidgetState createState() => DescriptionTextWidgetState();
}

class DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String? firstHalf;
  String? secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 50) {
      firstHalf = widget.text.substring(0, 50);
      secondHalf = widget.text.substring(50, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
      child: secondHalf!.isEmpty
          ? Text(firstHalf!, style: AppTheme.coloredSubtitle,)
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(flag ? ("$firstHalf...") : (firstHalf! + secondHalf!),
            style: AppTheme.coloredSubtitle,),
        ],
      ),
    );
  }
}
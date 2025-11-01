
import 'package:ezbus/gui/screens/routes_screen.dart';
import 'package:ezbus/gui/screens/sign_in_screen.dart';
import 'package:ezbus/gui/screens/stops_screen.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/connection/utils.dart';
import 'package:ezbus/gui/widgets/profile_menu.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';

import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/profile_pic.dart';
import 'about_screen.dart';
import 'change_language_screen.dart';
import 'terms_conditions_screen.dart';
import 'devices_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'my_profile_screen.dart';


class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}): super(key: key);
  @override
  ProfileScreen createState() => ProfileScreen();
}

class ProfileScreen extends State<MoreScreen> {
  bool isLoading = true;
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        if (isLoading) {
          thisApplicationViewModel.isUserLoggedIn().then((_) {
            setState(() {
              isLoading = false;
            });
          });
          return const Center(
              child: CircularProgressIndicator()
          );
        }
        else {
          return allProfileEntries(thisApplicationViewModel);
        }
      },
    );
  }

  Widget allProfileEntries(ThisApplicationViewModel thisApplicationViewModel) {
    return Stack(
      children: [
        Container(
          color: AppTheme.backgroundColor,
        ),
        SingleChildScrollView(
          //padding: EdgeInsets.symmetric(vertical: 5),
          child:
          Column(
            children: [
              SizedBox(height: 20.h),
              ProfilePic(thisApplicationViewModel: thisApplicationViewModel),
              SizedBox(height: 20.h),
              Container(
                decoration: const BoxDecoration(color: AppTheme.veryLightGrey),
                child:
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Column(
                          children: [
                            ProfileMenu(
                              backColor: Colors.blue,
                              text: translation(context)?.myProfile ?? 'My Profile',
                              icon: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white
                              ),
                              press: () {
                                goToScreen(
                                    context, thisAppModel, const MyProfileScreen());
                              },
                            ),
                            const Divider(thickness: 1,),
                            ProfileMenu(
                              backColor: Colors.greenAccent,
                              text: translation(context)?.stops ?? "Stops",
                              icon: const Icon(
                                  Icons.bus_alert,
                                  color: Colors.white
                              ),
                              press: () {
                                goToScreen(
                                    context, thisAppModel, const StopsScreen());
                              },
                            ),
                            const Divider(thickness: 1,),
                            ProfileMenu(
                              text: translation(context)?.routes ?? "Routes",
                              backColor: Colors.deepOrangeAccent,
                              icon: const Icon(
                                Icons.route_outlined,
                                color: Colors.white,
                              ),
                              press: () {
                                goToScreen(context, thisAppModel,
                                    const RoutesScreen());
                              },
                            ),
                            const Divider(thickness: 1,),
                            ProfileMenu(
                              text: translation(context)?.linkedDevices ?? "Linked devices",
                              backColor: Colors.blueGrey,
                              icon: const Icon(
                                Icons.devices,
                                color: Colors.white,
                              ),
                              press: () {
                                thisAppModel.getDevicesEndpoint();
                                goToScreen(context, thisAppModel,
                                    const DevicesScreen());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    children: [
                      ProfileMenu(
                        text: translation(context)?.changeLanguage ?? 'Change Language',
                        backColor: Colors.deepOrange,
                        icon: const Icon(
                          Icons.language,
                          color: Colors.white,
                        ),
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const ChangeLanguageScreen();
                              },
                            ),
                          );
                        },
                      ),
                      ProfileMenu(
                        text: translation(context)?.shareApp ??  "Share this App",
                        backColor: Colors.deepPurpleAccent,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        press: () {
                          _shareContent();
                        },
                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: translation(context)?.aboutApp ?? "About App",
                        backColor: Colors.lime,
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                        ),
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const AboutScreen();
                              },
                            ),
                          );
                        },

                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: translation(context)?.termsConditions ?? "Terms and Conditions",
                        backColor: Colors.lightBlue,
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const TermsConditionsScreen();
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(thickness: 1,),
                      ProfileMenu(
                        text: thisApplicationViewModel.isLoggedIn == true
                            ? (translation(context)?.logout ?? "Logout")
                            : (translation(context)?.login ?? "Login"),
                        backColor: thisApplicationViewModel.isLoggedIn == true
                            ? Colors.redAccent
                            : Colors.green,
                        icon: thisApplicationViewModel.isLoggedIn == true ?
                        const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ) : const Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                        press: () {
                          if (thisApplicationViewModel.isLoggedIn == true) {
                            showAlertLogoutDialog(
                                context, thisApplicationViewModel);
                          }
                          else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(widget),
                              ),
                            );
                          }
                        },
                      ),
                      thisApplicationViewModel.isLoggedIn == true ? const Divider(thickness: 1,) : Container(),
                      thisApplicationViewModel.isLoggedIn == true ? ProfileMenu(
                        text: thisApplicationViewModel.requestDeleteAccountLoadingState.inLoading() == true
                            ? ("Requesting ...")
                            : (translation(context)?.requestDelete ?? "Delete Account"),
                        backColor: Colors.red,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        press: () {
                          //display are you sure dialog
                          showAlertDeleteDialog(context, thisApplicationViewModel);
                        },
                      ): Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _shareContent() {
    ShareExtend.share(Config.shareText, "text");
  }

  void goToScreen(BuildContext context, ThisApplicationViewModel thisAppModel, Widget screen) {
    if(thisAppModel.isLoggedIn == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => screen,
        ),
      );
    }
    else
    {
      showLoginDialog(context, widget);
    }
  }
  void showAlertDeleteDialog(BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translation(context)?.requestDelete ?? "Request Delete"),
          content: Text(translation(context)?.requestDeleteMessage ?? "Are you sure you want to request account deletion? If you request account deletion, your account will be deleted after 3 days. You can cancel the request if you login to your account in the upcoming 3 days"),
          actions: <Widget>[
            TextButton(
              child: Text(translation(context)?.no ?? "No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(translation(context)?.yes ?? "Yes"),
              onPressed: () {
                thisApplicationViewModel.requestDeleteAccountEndpoint();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}



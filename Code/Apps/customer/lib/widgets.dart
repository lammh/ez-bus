import 'package:flutter/material.dart';
import 'package:ezbus/model/loading_state.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/utils/tools.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'connection/utils.dart';
import 'gui/languages/language_constants.dart';
import 'gui/screens/set_location_on_map_screen.dart';
import 'gui/screens/sign_in_screen.dart';
import 'gui/widgets/custom_surfix_icon.dart';
import 'gui/widgets/direction_positioned.dart';
import 'model/constant.dart';
import 'model/place.dart';
import 'model/push_notification.dart';

Widget showFailedView(BuildContext context, String? text, String? img, {bool showLogOut = false}) {

  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();

  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/$img.png', width: 160.0, height: 160.0,
        ),
        SizedBox(height: 20.h,),
        Text(text!, style: AppTheme.bold14DarkBlue, textAlign: TextAlign.center),
        showLogOut?Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                showAlertLogoutDialog(context, thisAppModel);
              }, child: Text(translation(context)?.logout ?? "Sign out")),
        ):Container(),
      ],
    ),
  );
}

onFailRequest(BuildContext context, FailState? reason, {LoadingState? loadSate}) {
  if(reason == null)
    {
      return showFailedView(context, Constant.noItem, "img_no_item");
    }
  if (reason == FailState.GENERAL) {
    if(loadSate != null) {
      return showFailedView(context, loadSate.error, "img_failed");
    } else {
      return showFailedView(context, Constant.failedText, "img_failed");
    }
  }
  else if (reason == FailState.UNAUTHENTICATED){
    return showFailedView(
        context, Constant.notAuthenticatedText, "lock", showLogOut: true);
  }
  else {
    return showFailedView(
        context, Constant.noInternetText, "img_no_internet");
  }
}

Widget displayDivider() {
  return const Divider(
    height: 2,
    color: Colors.grey,
  );
}


Widget failedScreen(BuildContext context, FailState? failState, {LoadingState? loadState}) {
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
              child: onFailRequest(context, failState!, loadSate: loadState),
            ),
          )
        ]
    );
}


Widget loadingScreen() {
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
            top: 20,
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      Text("Loading ...",
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
Widget signInOut(BuildContext context, Widget? widget) {
  return Center(
    child: Column(
      children: [
        SizedBox(height: 50.h,),
        Image.asset("assets/images/lock.png",
            height: 300.h,
            width: 200.w,
            alignment: Alignment.center),
        Text(translation(context)?.youNeedToLoginToContinue ?? "You need to login to continue.",
            style: AppTheme.textDarkBlueMedium),
        SizedBox(height: 50.h,),
        TextButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignInScreen(widget),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.primary,
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: SizedBox(
            height: 30.h,
            width: 250.w,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                translation(context)?.login ?? 'Sign In',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

TextFormField emailFormField(context, onSaveEmail, removeError, addError)
{
  return TextFormField(
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.emailAddress,
    onSaved: (newValue) => onSaveEmail(newValue),
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kEmailNullError);
      }
      if (AppTheme.emailValidatorRegExp.hasMatch(value)) {
        removeError(error: AppTheme.kInvalidEmailError);
      }
      onSaveEmail(value);
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kEmailNullError);
        return "";
      } else if (!AppTheme.emailValidatorRegExp.hasMatch(value)) {
        addError(error: AppTheme.kInvalidEmailError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.emailAddress ?? 'Email Address',
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: CustomSuffixIcon(svgIcon: Icon(
        Icons.email_outlined,
        color: AppTheme.primary,
      ),
      ),
    ),
  );
}

TextFormField passwordFormField(context, onSave, removeError, addError)
{
  return TextFormField(
    textInputAction: TextInputAction.done,
    obscureText: true,
    onSaved: (newValue) => onSave(newValue),
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kPassNullError);
      }
      if (value.length >= 8) {
        removeError(error: AppTheme.kShortPassError);
      }
      onSave(value);
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kPassNullError);
        return "";
      } else if (value.length < 8) {
        addError(error: AppTheme.kShortPassError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.password ?? 'Password',
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: const CustomSuffixIcon(
        svgIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.darkGrey,
        ),
      ),
    ),
  );
}

//confirm password text field
TextFormField confirmPasswordFormField(context, password, onSave, removeError, addError)
{
  String? confirmPassword = "";
  return TextFormField(
    textInputAction: TextInputAction.done,
    obscureText: true,
    onSaved: (newValue) => {
      onSave(newValue),
      confirmPassword = newValue
    },
    onChanged: (value) {
      confirmPassword = value;
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kConfirmPassNullError);
      }
      if (value.isNotEmpty && password == confirmPassword) {
        removeError(error: AppTheme.kMatchPassError);
      }
      onSave(value);
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kConfirmPassNullError);
        return "";
      } else if ((password != value)) {
        addError(error: AppTheme.kMatchPassError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.confirmPassword ?? "Confirm Password",
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: const CustomSuffixIcon(
        svgIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.darkGrey,
        ),
      ),
    ),
  );
}
TextFormField userNameFormField(context, onSave, removeError, addError)
{
  return TextFormField(
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.name,
    onSaved: (newValue) => onSave(newValue),
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: AppTheme.kNameNullError);
      }
      return;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: AppTheme.kNameNullError);
        return "";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: translation(context)?.userName ?? "User name",
      labelStyle: const TextStyle(
        color: AppTheme.normalGrey,
        fontSize: 16,
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: const CustomSuffixIcon(
        svgIcon: Icon(
          Icons.person,
          color: AppTheme.darkGrey,
        ),
      ),
    ),
  );
}

void showLoginDialog(BuildContext context, StatefulWidget nextScreen,
    {int? popCount}) {

  BuildContext backContext = context;

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translation(backContext)?.login ?? "Login"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/lock.png",
                  height: 200.h,
                  width: 200.w,
                  alignment: Alignment.center),
              const SizedBox(height: 30),
              Text(translation(backContext)?.youNeedToLoginToContinue ?? "You need to login to continue.",
                  style: AppTheme.textDarkBlueMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(translation(backContext)?.cancel ?? "Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (popCount != null) {
                  for (int i = 0; i < popCount; i++) {
                    Navigator.pop(backContext);
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(nextScreen),
                  ),
                );
              },
              child: Text(translation(backContext)?.login ?? "Login"),
            ),
          ],
        );
      });
}

void showPlaceNotSetDialog(BuildContext context, Place? place) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Address"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/img_no_place.png",
                  height: 200.h,
                  width: 200.w,
                  alignment: Alignment.center),
              const SizedBox(height: 30),
              Text("The address is not set. Do you want to set it now?",
                  style: AppTheme.textDarkBlueMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SetLocationOnMapScreen(currentPlace: place, action: "EditPlace",)),
                );
              },
              child: const Text("Set address"),
            ),
          ],
        );
      });
}

void showNotificationDialog(BuildContext context, PushNotification notification) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(notification.title!),
        content: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100.0.h,
                width: 100.0.w,
                child: const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                        "assets/images/notification.png"),
                    backgroundColor: AppTheme.lightGrey,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Text(notification.body!)
            ],
          ),
        ),
      );
    },
  );
}
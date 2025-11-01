
import 'dart:io';

import 'package:ezbusdriver/gui/screens/payment_methods_screen.dart';
import 'package:ezbusdriver/gui/screens/sign_in_screen.dart';
import 'package:ezbusdriver/gui/screens/terms_conditions_screen.dart';
import 'package:flutter/material.dart';
import 'package:ezbusdriver/connection/utils.dart';
import 'package:ezbusdriver/gui/widgets/profile_menu.dart';
import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/profile_pic.dart';
import 'about_screen.dart';
import 'change_language_screen.dart';
import 'devices_screen.dart';
import 'my_profile_screen.dart';


class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}): super(key: key);
  @override
  MoreScreenState createState() => MoreScreenState();
}

class MoreScreenState extends State<MoreScreen> {
  bool isLoading = true;
  ThisApplicationViewModel thisAppModel = serviceLocator<ThisApplicationViewModel>();
  final ImagePicker _picker = ImagePicker();

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
          if (thisApplicationViewModel.isLoggedIn!) {
            return allProfileEntries(thisApplicationViewModel);
          }
          else {
            return signInOut(context, null);
          }
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
                              text: translation(context)?.linkedDevices ??  "Linked devices",
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
                            //payment methods
                            const Divider(thickness: 1,),
                            ProfileMenu(
                              text: translation(context)?.paymentMethods ?? "Payment methods",
                              backColor: Colors.green,
                              icon: const Icon(
                                Icons.payment,
                                color: Colors.white,
                              ),
                              press: () {
                                goToScreen(context, thisAppModel,
                                    const PaymentMethodsScreen());
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
                      //profile menu to change language
                      ProfileMenu(
                        text: translation(context)?.changeLanguage ?? 'Change Language',
                        backColor: Colors.deepOrange,
                        icon: const Icon(
                          Icons.language,
                          color: Colors.white,
                        ),
                        press: () {
                          goToScreen(context, thisAppModel, const ChangeLanguageScreen());
                        },
                      ),
                      ProfileMenu(
                        text: translation(context)?.shareApp ?? "Share this App",
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
                      const Divider(thickness: 1,),
                      ProfileMenu(
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
                      ),
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
    ShareExtend.share("Let's go anywhere with the smart bus system EzBus! It's simple, easy and secure app.", "text");
  }

  void changeProfilePicture(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 150.h,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(translation(context)?.camera ?? 'Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  String? fileName = await pickProfileImage(ImageSource.camera);
                  if(fileName != null){
                    thisAppModel.uploadAvatarEndpoint(fileName);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(translation(context)?.gallery ?? 'Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  String? fileName = await pickProfileImage(ImageSource.gallery);
                  if(fileName != null){
                    thisAppModel.uploadAvatarEndpoint(fileName);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> pickProfileImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    //copy image to app directory
    String cow = await createFolder('driver_documents');
    File file = File(pickedFile!.path);
    String fileName = basename(file.path);
    File newImage = await file.copy('$cow/$fileName');
    return newImage.path;
  }

  Future<String> createFolder(String cow) async {
    final dir = Directory('${(Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory() //FOR IOS
    )!
        .path}/$cow');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }

  String basename(String path) {
    return path.split('/').last;
  }

  void goToScreen(BuildContext context, ThisApplicationViewModel thisAppModel, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
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



import 'dart:io';

import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';
import '../../utils/app_theme.dart';
import '../../utils/config.dart';
import '../languages/language_constants.dart';
class ProfilePic extends StatelessWidget {
  final ThisApplicationViewModel thisApplicationViewModel;
  ProfilePic({
    Key? key, required this.thisApplicationViewModel,
  }) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      width: 115,
      child: Stack(
        clipBehavior: Clip.none, fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 115,
              width: 115,
              child: thisApplicationViewModel.isLoggedIn == true ?
              CircleAvatar(
                backgroundImage: NetworkImage("${Config.serverUrl}${thisApplicationViewModel.currentUser?.avatar}"),
                backgroundColor: AppTheme.veryLightGrey,
              ) :
              const CircleAvatar(
                backgroundImage: AssetImage("assets/images/avatar.png"),
                backgroundColor: AppTheme.lightGrey,
              ),
            ),
          ),
          thisApplicationViewModel.isLoggedIn == true ?
          DirectionPositioned(
            bottom: 55,
            right: -16,
            child: SizedBox(
              height: 46,
              width: 46,
              child: thisApplicationViewModel.uploadAvatarLoadingState.inLoading() == true ?
              const CircularProgressIndicator(
                color: AppTheme.primary,
              ) :
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightGrey,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: AppTheme.lightGrey),
                    ),
                    elevation: 5),
                onPressed: () {
                  changeProfilePicture(context);
                },
                child: const Icon(
                  Icons.camera_alt_outlined,
                ),
              ),
            ),
          ) : Container(),
          //user name
          DirectionPositioned(
            bottom: 20,
            left: 0,
            right: 0,
            child:
            Text(thisApplicationViewModel.isLoggedIn == true
                ? thisApplicationViewModel.currentUser?.name ?? "Guest"
                : "Guest",
              textAlign: TextAlign.center,
              style: AppTheme.bold20DarkBlue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,),
          ),
          //email
          DirectionPositioned(
            bottom: 0,
            child: Text(
              thisApplicationViewModel.isLoggedIn == true
                  ? thisApplicationViewModel.currentUser?.email ?? ""
                  : "",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
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
                      thisApplicationViewModel.uploadAvatarEndpoint(fileName);
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
                    thisApplicationViewModel.uploadAvatarEndpoint(fileName);
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
}

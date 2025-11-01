import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:ezbusdriver/gui/widgets/app_bar.dart';
import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:provider/provider.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class PickUpScreen extends StatefulWidget {
  final int? tripID;
  final Position? currentLocation;
  const PickUpScreen(this.tripID, this.currentLocation, {super.key});

  @override
  PickUpScreenState createState() => PickUpScreenState();
}

class PickUpScreenState extends State<PickUpScreen> {
  CameraController? controller;
  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  List<CameraDescription>? _cameras;
  bool cameraReady = false;
  bool? cameraAccessDenied;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  @override
  void initState() {
    super.initState();

    availableCameras().then((value)
    {
      _cameras = value;
      if(_cameras == null || _cameras!.isEmpty)
      {
        return;
      }
      controller = CameraController(
          _cameras![0],
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.nv21 // for Android
              : ImageFormatGroup.bgra8888, // for iOS
          ResolutionPreset.max);
      controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {

        });
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
            // Handle access errors here.
            setState(() {
              cameraAccessDenied = true;
            });
              break;
            default:
            // Handle other errors here.
              break;
          }
        }
      });
    });

  }

  // InputImage? _inputImageFromCameraImage(CameraImage image) {
  //   // get image rotation
  //   // it is used in android to convert the InputImage from Dart to Java
  //   // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
  //   // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
  //   final camera = _cameras![0];
  //   final sensorOrientation = camera.sensorOrientation;
  //   InputImageRotation? rotation;
  //   if (Platform.isIOS) {
  //     rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  //   } else if (Platform.isAndroid) {
  //     var rotationCompensation =
  //     _orientations_orientations[controller!.value.deviceOrientation];
  //     if (rotationCompensation == null) return null;
  //     if (camera.lensDirection == CameraLensDirection.front) {
  //       // front-facing
  //       rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
  //     } else {
  //       // back-facing
  //       rotationCompensation =
  //           (sensorOrientation - rotationCompensation + 360) % 360;
  //     }
  //     rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  //   }
  //   if (rotation == null) return null;
  //
  //   // get image format
  //   final format = InputImageFormatValue.fromRawValue(image.format.raw);
  //   // validate format depending on platform
  //   // only supported formats:
  //   // * nv21 for Android
  //   // * bgra8888 for iOS
  //   if (format == null ||
  //       (Platform.isAndroid && format != InputImageFormat.nv21) ||
  //       (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;
  //
  //   // since format is constraint to nv21 or bgra8888, both only have one plane
  //   if (image.planes.length != 1) return null;
  //   final plane = image.planes.first;
  //
  //   // compose InputImage using bytes
  //   return InputImage.fromBytes(
  //     bytes: plane.bytes,
  //     metadata: InputImageMetadata(
  //       size: Size(image.width.toDouble(), image.height.toDouble()),
  //       rotation: rotation, // used only in Android
  //       format: format, // used only in iOS
  //       bytesPerRow: plane.bytesPerRow, // used only in iOS
  //     ),
  //   );
  // }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      _showCameraError('Camera is not initialized.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      _showCameraError('A capture is already pending, do nothing.');
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraError(e.description);
      return null;
    }
  }

  void _showCameraError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? "",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    thisAppModel.pickupPassengerLoadingState.error = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      //show loading spinner
      return loadingScreen(context);
    }
    else {
      if (cameraAccessDenied == true) {
        return Scaffold(
          appBar: buildAppBar(context, translation(context)?.scanTicket ?? 'Scan Ticket'),
          body: const Center(
            child: Text(
              'Camera access denied',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (thisAppModel.pickupPassengerLoadingState.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    thisAppModel.pickupPassengerLoadingState
                        .error!,
                  ),
                ),
              );
              thisAppModel.pickupPassengerLoadingState.error = null;
            }

            if (thisAppModel.updateBusLocationResponse!
                .countPassengersToBePickedUp == 0) {
              //wait 100 milliseconds before popping the screen
              Future.delayed(const Duration(milliseconds: 500), () {
                dispose();
                Navigator.pop(context);
              });
            }
            // else if (thisAppModel.pickupPassengerLoadingState.error == null &&
            //     thisAppModel.pickupPassengerLoadingState.loadingFinished()) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       content: Text(
            //         "Passenger picked up successfully",
            //       ),
            //     ),
            //   );
            // }
          });
          return Scaffold(
            appBar: buildAppBar(context, 'Scan Ticket'),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20,),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text("${thisAppModel.updateBusLocationResponse!
                                  .countPassengersToBePickedUp} ${thisAppModel.updateBusLocationResponse!
                                  .countPassengersToBePickedUp==1?"Passenger":"Passengers"}", style: AppTheme.textDarkBlueLarge,)
                          ),
                          SizedBox(height: 50.h,),
                          Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text("Place QR code in the middle of the box", style: AppTheme.textDarkBlueSmall,),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  SizedBox(
                    width: 270.w,
                    height: 270.w,
                    child: CameraPreview(controller!),
                  ),
                  SizedBox(height: 10.h,),
                  Center(
                    child: ElevatedButton(
                      child: Padding(
                        padding: EdgeInsets.only(left:20.w, right: 20.w, top: 15.h, bottom: 15.h),
                        child: thisAppModel.pickupPassengerLoadingState
                            .inLoading() ?
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ) :
                        Text('Scan (${thisAppModel.updateBusLocationResponse!
                            .countPassengersToBePickedUp})', style: AppTheme.textWhiteMedium,)),
                      onPressed: () async {
                        final image = await takePicture();

                        if (image == null) {
                          return;
                        }
                        final inputImage = InputImage.fromFilePath(
                            image.path);
                        final List<
                            Barcode> barcodes = await barcodeScanner
                            .processImage(inputImage);
                        //make HapticFeedback and beep
                        HapticFeedback.vibrate();
                        FlutterRingtonePlayer().playNotification();
                        if (barcodes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No QR code found',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          return;
                        }
                        else {
                          thisAppModel.pickupPassengerLoadingState
                              .error = null;
                          thisAppModel.pickupPassengerEndpoint(
                              barcodes[0].displayValue,
                              widget.tripID,
                              widget.currentLocation?.latitude,
                              widget.currentLocation?.longitude,
                              widget.currentLocation?.speed);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: StadiumBorder()
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Passengers do not show up? Report below", style: AppTheme.textDarkBlueSmall,),
                    ),
                  ),
                  SizedBox(height: 5.h,),
                  ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.only(left:20.w, right: 20.w, top: 15.h, bottom: 15.h),
                      child: Text(
                          "Passengers do not show up",
                          style: AppTheme.textWhiteMedium
                      ),
                    ),
                    onPressed: () async {
                      showOkCancelDialog(
                          context,
                          thisAppModel,
                          "No Passengers",
                          "Are you sure you want to mark these passengers as not show up?",
                          "Yes",
                          "No",
                              () {
                            Navigator.of(context, rootNavigator: true)
                                .pop();
                            thisAppModel.pickupPassengerLoadingState
                                .error = null;
                            thisAppModel.pickupPassengerEndpoint(
                                null,
                                widget.tripID,
                                widget.currentLocation?.latitude,
                                widget.currentLocation?.longitude,
                                widget.currentLocation?.speed);
                          },
                              () {
                            Navigator.of(context, rootNavigator: true)
                                .pop();
                          }
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colorSecondary,
                        shape: StadiumBorder()
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<ThisApplicationViewModel>(
  //     builder: (context, thisApplicationViewModel, child) {
  //       return Scaffold(
  //           appBar: buildAppBar(context, 'FAQ'),
  //           body: displayHtml(thisApplicationViewModel)
  //       );
  //     },
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: buildAppBar(context, 'Scan Ticket'),
  //     body: Column(
  //       children: <Widget>[
  //         Expanded(
  //           flex: 5,
  //           child: QRView(
  //             key: qrKey,
  //             onQRViewCreated: _onQRViewCreated,
  //           ),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Center(
  //             child: (result != null)
  //                 ? Text(
  //                 'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
  //                 : Text('Scan a code'),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //       print("TESSSSST:"+result!.code!);
  //     });
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }
}
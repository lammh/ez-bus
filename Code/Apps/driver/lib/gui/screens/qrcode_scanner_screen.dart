import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../utils/app_theme.dart';
import '../../view_models/this_application_view_model.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/app_bar.dart';

class QrcodeScannerScreen extends StatefulWidget {
  const QrcodeScannerScreen(this.tripID, this.currentLocation, {super.key});
  final Position? currentLocation;
  final int? tripID;

  @override
  _QrcodeScannerScreenState createState() =>
      _QrcodeScannerScreenState();
}

class _QrcodeScannerScreenState extends State<QrcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  DateTime? lastScanTime;
  String? lastQrCodeValue;


  @override
  Widget build(BuildContext context) {
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

            if (thisAppModel.updateBusLocationResponse != null &&
                thisAppModel.updateBusLocationResponse!
                    .countPassengersToBePickedUp == 0) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }
            }
          });
          final scanWindow = Rect.fromCenter(
            //make it a little to the top
            center: MediaQuery
                .of(context)
                .size
                .center(Offset(0, -50)),
            width: 200,
            height: 200,
          );
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: buildAppBar(context, 'Scan Ticket'),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: MobileScanner(
                    fit: BoxFit.contain,
                    controller: controller,
                    scanWindow: scanWindow,
                    onDetect: (BarcodeCapture barcodes) {
                      if (barcodes.barcodes.isEmpty) {
                        return;
                      }
                      if (lastScanTime != null &&
                          DateTime
                              .now().difference(lastScanTime!)
                              .inSeconds < 5 && lastQrCodeValue == barcodes.barcodes.first.displayValue) {
                        return;
                      }
                      print('Barcode detected: ${barcodes.barcodes.first.displayValue}');
                      //make HapticFeedback and beep
                      HapticFeedback.vibrate();
                      FlutterRingtonePlayer().playNotification();
                      thisAppModel.pickupPassengerLoadingState
                          .error = null;
                      thisAppModel.pickupPassengerEndpoint(
                          barcodes.barcodes.first.displayValue, //"123456789",
                          widget.tripID,
                          widget.currentLocation?.latitude,
                          widget.currentLocation?.longitude,
                          widget.currentLocation?.speed);
                      lastScanTime = DateTime.now();
                      lastQrCodeValue = barcodes.barcodes.first.displayValue;
                      print("scannedBarcodes " + lastScanTime.toString());
                    },
                    errorBuilder: (context, error, child) {
                      return const Center(
                        child: Text('Error: Could not start camera'),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    if (!value.isInitialized ||
                        !value.isRunning ||
                        value.error != null) {
                      return const SizedBox();
                    }

                    return CustomPaint(
                      painter: ScannerOverlay(scanWindow: scanWindow),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("Place QR code in the middle of the box",
                          style: AppTheme.textWhiteMedium,),
                        const SizedBox(height: 16),
                        Text("OR", style: AppTheme.textWhiteMedium,),
                        const SizedBox(height: 16),
                        ElevatedButton(
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
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10.w, right: 10.w, top: 10.h, bottom: 10.h),
                            child: Text(
                                "Passengers do not show up",
                                style: AppTheme.textWhiteMedium
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: thisAppModel.updateBusLocationResponse != null ?
                    Text("${thisAppModel.updateBusLocationResponse!
                        .countPassengersToBePickedUp} ${thisAppModel.updateBusLocationResponse!
                        .countPassengersToBePickedUp==1?"Passenger":"Passengers"}", style: AppTheme.textWhiteMedium,)
                        : const SizedBox(),
                  ),
                ),
              ],
            ),
          );
        });
  }


  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}



class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
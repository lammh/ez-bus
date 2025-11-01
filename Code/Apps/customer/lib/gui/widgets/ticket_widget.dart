import 'package:barcode_widget/barcode_widget.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_dashed_line.dart';
import 'package:ezbus/gui/widgets/RouteWidget/route_widget_marker.dart';
import 'package:ezbus/gui/widgets/direction_positioned.dart';
import 'package:ezbus/gui/widgets/direction_row.dart';
import 'package:ezbus/model/reservation.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/service_locator.dart';
import '../../utils/tools.dart';
import '../languages/language_constants.dart';

class TicketContentWidget extends StatefulWidget{
  final bool isDialog;
  final int index;
  final Reservation reservation;
  const TicketContentWidget({super.key, 
    required this.isDialog,
    required this.index, 
    required this.reservation});
  @override
  State<StatefulWidget> createState() => _TicketWidgetState();

}
class _TicketWidgetState extends State<TicketContentWidget> {
  late bool isDialog;
  late int idx;
  late Reservation reservation;
  ThisApplicationViewModel thisApplicationViewModel = serviceLocator<
      ThisApplicationViewModel>();

  @override
  void initState() {
    isDialog = widget.isDialog;
    idx = widget.index;
    reservation = widget.reservation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Hero(
            tag: 'tripCard$idx',
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 350.w,
                child: DirectionRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      Tools.formatTime(reservation.plannedStartTime),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: AppTheme.textDarkBlueLarge,
                    ),
                    Text(
                      Tools.getFormattedDateOnly(DateTime
                          .parse(reservation.trip!.plannedDate!)
                          .millisecondsSinceEpoch,
                          Localizations.localeOf(context)),
                      style: AppTheme.textGreyLarge,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: 400.w,
              height: isDialog ? 350.h : 200.h,
              child: Stack(
                children: [
                  isDialog == false ?
                  DirectionPositioned(
                    left: -60.w,
                    child: Hero(
                      tag: 'route$idx',
                      child: SizedBox(
                        width: 300.w,
                        child: Material(
                          color: Colors.transparent,
                          child: RouteWidget(
                            children: [
                              RouteWidgetMarker(
                                leading: const SizedBox(),
                                trailing: Text(
                                  reservation.firstStop!.name!,
                                  style: AppTheme.textlightPrimaryMedium,
                                ),
                              ),
                              const RouteWidgetDashedLine(
                                trailing: SizedBox(),
                                walking: false,
                              ),
                              RouteWidgetMarker(
                                leading: const SizedBox(),
                                trailing: SizedBox(
                                  width: 140.w,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reservation.destinationAddress!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.textGreySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                  DirectionPositioned(
                    top: isDialog ? 10.h : 0,
                    right: isDialog ? 10.w : 20.w,
                    left: isDialog ? 10.w : null,
                    bottom: isDialog ? 0 : null,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'qr1$idx',
                          child: BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: '${reservation.ticketNumber}',
                            width: isDialog ? 200.w : 94.w,
                            height: isDialog ? 200.w : 94.w,
                            color: reservation.paymentMethod == 0
                                ? Colors.black
                                : Colors.red,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Hero(
                          tag: 'price1$idx',
                          child: Material(
                            color: Colors.transparent,
                            child: thisApplicationViewModel.settings
                                ?.paymentMethod != "none" ?
                            Text(
                              Tools.formatPrice(thisApplicationViewModel,
                                  reservation.paidPrice!),
                              textAlign: TextAlign.center,
                              style: AppTheme.textdarkPrimaryLarge,
                            ) : Container(),
                          ),
                        ),
                        SizedBox(height: isDialog ? 10.h : 5.h),
                        Hero(
                          tag: 'paid1$idx',
                          child: Material(
                            color: Colors.transparent,
                            child:
                            thisApplicationViewModel.settings?.paymentMethod !=
                                "none" ?
                            Text(
                              reservation.paymentMethod == 0 ?
                              ((translation(context)?.paidOn ?? 'Paid on ') +
                                  reservation.reservationDate!) : (translation(
                                  context)?.cash ?? 'Cash'),
                              style: AppTheme.textGreySmall,
                            ) : Container(),
                          ),
                        ),
                        SizedBox(height: isDialog ? 10.h : 5.h),
                        (thisApplicationViewModel.settings
                            ?.allowSeatSelection != null &&
                        thisApplicationViewModel.settings?.allowSeatSelection == true &&
                        reservation.seatNumber != null) ?
                        Hero(
                          tag: 'seat1$idx',
                          child: Material(
                            color: Colors.transparent,
                            child: Wrap(
                              children: [
                                //icon
                                Icon(
                                  Icons.event_seat,
                                  color: AppTheme.darkPrimary,
                                  size: 20.sp,
                                ),
                                Text(
                                  reservation.seatNumber!.toString(),
                                  style: AppTheme.textDarkBlueMedium,
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                //row icon
                                reservation.row != null?
                                Icon(
                                  Icons.table_rows,
                                  color: AppTheme.darkPrimary,
                                  size: 20.sp,
                                ) : Container(),
                                reservation.row != null?
                                Text(
                                  (reservation.row! + 1).toString(),
                                  style: AppTheme.textDarkBlueMedium,
                                )
                                    : Container(),

                                SizedBox(
                                  width: 1.w,
                                ),

                                reservation.column != null?
                                Icon(
                                  Icons.view_column,
                                  color: AppTheme.darkPrimary,
                                  size: 20.sp,
                                ) : Container(),

                                reservation.column != null?
                                Text(
                                  (reservation.column! + 1).toString(),
                                  style: AppTheme.textDarkBlueMedium,
                                )
                                    : Container(),
                              ],
                            ),
                          ),
                        ) : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
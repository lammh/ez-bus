

// ignore: unused_import
import 'package:ezbusdriver/model/device.dart';

import '../../model/reservation.dart';
import '../../model/stop.dart';

class UpdateBusLocationResponse {
  Stop? nextStop;
  bool? success;
  double? distanceToNextStop;
  int? countPassengersToBePickedUp;
  String? nextStopPlannedTime;
  List<dynamic>? passengersToBeDroppedOff;
  UpdateBusLocationResponse({this.nextStop, this.success, this.distanceToNextStop,
    this.countPassengersToBePickedUp,
    this.nextStopPlannedTime,
    this.passengersToBeDroppedOff});

  factory UpdateBusLocationResponse.fromJson(Map<String, dynamic> json) {
    return UpdateBusLocationResponse(
        nextStop: json['next_stop'] != null ? Stop.fromJson(json['next_stop']) : null,
        success: json['success'],
        distanceToNextStop: json['distance_to_next_stop'],
        nextStopPlannedTime: json['next_stop_planned_time'],
        countPassengersToBePickedUp: json['count_passengers_to_be_picked_up'],
        passengersToBeDroppedOff: json['passengers_to_be_dropped_off'] != null ? (json['passengers_to_be_dropped_off']).map((i) => Reservation.fromJson(i)).toList() : null,
    );
  }
}
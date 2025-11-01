
import 'package:ezbus/model/route_info.dart';
import 'package:ezbus/model/trip_details.dart';
import 'package:ezbus/model/user.dart';

import 'bus.dart';

class Trip{
  Trip({
    this.id,
    this.channel,
    this.routeId,
    this.effectiveDate,
    this.repetitionPeriod,
    this.stopToStopAvgTime,
    this.firstStopTime,
    this.lastStopTime,
    this.plannedDate,
    this.route,
    this.tripDetail,
    this.plannedTripDetail,
    this.lastPositionLat,
    this.lastPositionLng,
    this.startedAt,
    this.endedAt,
    this.driver,
    this.bus,
  });
  int? id;
  String? channel;
  int? routeId;
  String? effectiveDate;
  int? repetitionPeriod;
  int? stopToStopAvgTime;
  String? firstStopTime;
  String? lastStopTime;
  String? plannedDate;
  RouteInfo? route;
  double? lastPositionLat, lastPositionLng;
  List<dynamic>? tripDetail, plannedTripDetail;
  String? startedAt, endedAt;
  DbUser? driver;
  Bus? bus;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel,
      'route_id': routeId,
      'effective_date': effectiveDate,
      'repetition_period': repetitionPeriod,
      'stop_to_stop_avg_time': stopToStopAvgTime,
      'first_stop_time': firstStopTime,
      'last_stop_time': lastStopTime,
      'planned_date': plannedDate,
      'route': route,
      'trip_detail': tripDetail,
      'planned_trip_detail': plannedTripDetail,
      'last_position_lat' : lastPositionLat,
      'last_position_lng' : lastPositionLng,
      'started_at' : startedAt,
      'ended_at' : endedAt,
      'driver': driver != null ? driver!.toJson() : '',
      'bus': bus != null ? bus!.toJson() : '',
    };
  }

  static Trip fromJson(json) {
    return Trip(
      id: json['id'],
      channel: json['channel'],
      routeId: json['route_id'],
      effectiveDate: json['effective_date'],
      repetitionPeriod: json['repetition_period'],
      stopToStopAvgTime: json['stop_to_stop_avg_time'],
      firstStopTime: json['first_stop_time'],
      lastStopTime: json['last_stop_time'],
      plannedDate: json['planned_date'],
      lastPositionLat: json['last_position_lat'] != null ? double.parse(json['last_position_lat'].toString()) : null,
      lastPositionLng: json['last_position_lng'] != null ? double.parse(json['last_position_lng'].toString()) : null,
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
      tripDetail: json['trip_detail'] != null ? json['trip_detail'].map((p) => TripDetails.fromJson(p)).toList() : null,
      plannedTripDetail: json['planned_trip_detail'] != null ? json['planned_trip_detail'].map((p) => TripDetails.fromJson(p)).toList() : null,
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
      driver: json['driver'] != null ? DbUser.fromJson(json['driver']) : null,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
    );
  }
}
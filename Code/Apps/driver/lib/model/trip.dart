
import 'package:ezbusdriver/model/route_info.dart';
import 'package:ezbusdriver/model/trip_details.dart';

class Trip{
  Trip({
    this.id,
    this.channel,
    this.routeId,
    this.plannedDate,
    this.route,
    this.reservedSeats,
    this.tripDetail,
    this.plannedTripDetail,
    this.startedAt,
    this.endedAt,
  });
  int? id;
  String? channel;
  int? routeId;
  String? plannedDate;
  //started_at
  DateTime? startedAt;
  DateTime? endedAt;

  RouteInfo? route;
  int? reservedSeats;
  List<dynamic>? tripDetail, plannedTripDetail;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel': channel,
      'route_id': routeId,
      'planned_date': plannedDate,
      'route': route,
      'reserved_seats': reservedSeats,
      'trip_detail': tripDetail,
      'planned_trip_detail': plannedTripDetail,
      'started_at': startedAt?.toIso8601String() ?? '',
      'ended_at': endedAt?.toIso8601String() ?? '',
    };
  }

  static Trip fromJson(json) {
    return Trip(
      id: json['id'],
      channel: json['channel'],
      routeId: json['route_id'],
      plannedDate: json['planned_date'],
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
      reservedSeats: json['reserved_seats'],
      tripDetail: json['trip_detail'] != null ? json['trip_detail'].map((p) => TripDetails.fromJson(p)).toList() : null,
      plannedTripDetail: json['planned_trip_detail'] != null ? json['planned_trip_detail'].map((p) => TripDetails.fromJson(p)).toList() : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
    );
  }
}
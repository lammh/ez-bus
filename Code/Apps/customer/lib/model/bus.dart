import 'dart:convert';

import '../gui/screens/seats_screen.dart';
import 'bus_configuration.dart';

class Bus{
    int id;
    String license;
    int capacity;
    String seatConfig;
    int driverId;
    double priceFactor;

    BusConfiguration? busConfiguration;

    Bus(
        {required this.id,
            required this.license,
            required this.capacity,
            required this.seatConfig,
            required this.driverId,
            required this.priceFactor}
        )
    {
        //convert from json string seatConfig to Map<String, dynamic>
        Map<String, dynamic> jsonMap = JsonDecoder().convert(seatConfig);
        //json['rows'], json['columns'], json['seat_grid'], json['booked_seats'] from seatConfig string

        busConfiguration = BusConfiguration.fromJson(jsonMap);
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'license': license,
            'capacity': capacity,
            'seat_config': seatConfig,
            'driver_id': driverId,
            'price_factor': priceFactor,
        };
    }

    static Bus fromJson(json) {
        return Bus(
            id: json['id'],
            license: json['license'],
            capacity: json['capacity'],
            seatConfig: json['seat_config'],
            driverId: json['driver_id'],
            priceFactor: json['price_factor']!=null? double.parse(json['price_factor'].toString()):0.0,
        );
    }

}

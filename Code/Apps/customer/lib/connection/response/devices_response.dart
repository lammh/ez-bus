

import 'package:ezbus/model/device.dart';

class DevicesResponse {
  List<Device>? items = [];

  DevicesResponse({this.items});

  factory DevicesResponse.fromJson(List<dynamic> list) {
    return DevicesResponse(
        items: list.map((p) => Device.fromJson(p)).toList()
    );
  }
}
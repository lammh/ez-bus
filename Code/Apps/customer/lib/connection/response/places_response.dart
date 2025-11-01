

import 'package:ezbus/model/place.dart';

class PlacesResponse {
  List<Place>? items = [];

  PlacesResponse({this.items});

  factory PlacesResponse.fromJson(List<dynamic> list) {
    return PlacesResponse(
        items: list.map((p) => Place.fromJson(p)).toList()
    );
  }
}
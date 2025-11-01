import 'package:ezbusdriver/model/driver_data.dart';
import 'package:ezbusdriver/model/my_notification.dart';
import 'package:ezbusdriver/model/setting.dart';
import 'package:ezbusdriver/model/user.dart';

class AuthResponse {
  DbUser? user;
  String? token;
  List<MyNotification>? userNotifications = [];
  DriverData? driverData;
  Setting? settings;

  AuthResponse({this.user, this.driverData, this.token, this.userNotifications, this.settings});

  factory AuthResponse.fromJson(json) {
    List<dynamic>? notificationsList = json['user_notifications'];
    return AuthResponse(
        user : json['user_data'] != null? DbUser.fromJson(json['user_data']) : null,
        token: json['token'],
        userNotifications: notificationsList?.map((p) => MyNotification.fromJson(p)).toList(),
        settings: json['settings'] != null? Setting.fromJson(json['settings']) : null,
        driverData: json['driver_data'] != null? DriverData.fromJson(json['driver_data']) : null
    );
  }
}
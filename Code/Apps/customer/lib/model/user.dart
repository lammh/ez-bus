
import 'driver_data.dart';

class DbUser{

    int? id, role;
    String? name, email, uid, fcmToken, avatar;
    double? wallet;
    String? address, telNumber;
    DriverData? driverData;


    DbUser(
        {this.id,
            this.name,
            this.email,
            this.uid,
            this.fcmToken,
            this.role,
            this.avatar,
            this.wallet,
            this.address,
            this.telNumber,
            this.driverData }
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'email': email,
            'uid': uid,
            'fcm_token': fcmToken,
            'role':role,
            'avatar':avatar,
            'wallet':wallet,
            'address': address,
            'tel_number': telNumber,
            'driver_information': driverData!=null? driverData!.toJson():null,
        };
    }

    static DbUser fromJson(json) {
        return DbUser(
            id: json['id'],
            name: json['name'],
            email: json['email'],
            uid: json['uid'],
            role: json['role'],
            avatar: json['avatar'],
            wallet: json['wallet']!=null? double.parse(json['wallet'].toString()):0.0,
            fcmToken: json['fcm_token'],
            address: json['address'],
            telNumber: json['tel_number'],
            driverData: json['driver_information']!=null? DriverData.fromJson(json['driver_information']):null,
        );
    }

}

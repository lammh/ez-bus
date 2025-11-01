
import 'package:ezbusdriver/model/pay_pal_account.dart';

import 'mobile_money_account.dart';
import 'bank_account.dart';

class DbUser{

    int? id, role, statusID;
    String? name, email, uid, fcmToken, avatar;
    double? rate, wallet;
    String? address, telNumber;

    BankAccount? bankAccount;
    PayPalAccount? payPalAccount;
    MobileMoneyAccount? mobileMoneyAccount;

    int? preferredPaymentMethod;

    DbUser(
        {this.id,
            this.name,
            this.email,
            this.uid,
            this.fcmToken,
            this.role,
            this.statusID,
            this.rate,
            this.wallet,
            this.address,
            this.telNumber,
            this.avatar,
            this.bankAccount,
            this.payPalAccount,
            this.mobileMoneyAccount,
            this.preferredPaymentMethod}
        );

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'email': email,
            'uid': uid,
            'fcm_token': fcmToken,
            'role':role,
            'status_id':statusID,
            'rate':rate,
            'wallet':wallet,
            'address': address,
            'tel_number': telNumber,
            'avatar':avatar,
            'redemption_preference':preferredPaymentMethod,
            'bank_account': bankAccount!=null? bankAccount!.toJson():null,
            'paypal_account': payPalAccount!=null? payPalAccount!.toJson():null,
            'mobile_money_account': mobileMoneyAccount!=null? mobileMoneyAccount!.toJson():null,
        };
    }

    static DbUser fromJson(json) {
        return DbUser(
            id: json['id'],
            name: json['name'],
            email: json['email'],
            uid: json['uid'],
            role: json['role'],
            statusID: json['status_id'],
            rate: json['rate']!=null? double.parse(json['rate'].toString()):0.0,
            wallet: json['wallet']!=null? double.parse(json['wallet'].toString()):0.0,
            fcmToken: json['fcm_token'],
            address: json['address'],
            telNumber: json['tel_number'],
            avatar: json['avatar'],
            preferredPaymentMethod: json['redemption_preference'],
            bankAccount: json['bank_account']!=null? BankAccount.fromJson(json['bank_account']):null,
            payPalAccount: json['paypal_account']!=null? PayPalAccount.fromJson(json['paypal_account']):null,
            mobileMoneyAccount: json['mobile_money_account']!=null? MobileMoneyAccount.fromJson(json['mobile_money_account']):null,
        );
    }

}

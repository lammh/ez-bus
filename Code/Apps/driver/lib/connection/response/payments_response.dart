
import 'package:ezbusdriver/model/payment_info.dart';

class PaymentsResponse {
  List<PaymentInfo>? items = [];
  double? walletBalance;
  bool? success;
  String? message;
  String? currencyCode;
  bool? showAds;
  PaymentsResponse({this.items, this.walletBalance, this.success, this.message,
    this.currencyCode, this.showAds});

  factory PaymentsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['payments'] as List;
    var walletBalance = json['wallet_balance'];
    return PaymentsResponse(
        items: list.map((p) => PaymentInfo.fromJson(p)).toList(),
        walletBalance: walletBalance != null ? double.parse(walletBalance.toString()) : 0,
        success: json['success'],
        message: json['message'],
        currencyCode: json['currency_code'],
        showAds: json['allow_ads_in_driver_app']!=null? (json['allow_ads_in_driver_app'] == 1 ? true : false) : false,
    );
  }
}
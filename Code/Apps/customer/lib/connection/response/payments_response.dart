
import 'package:ezbus/model/payment_info.dart';

class PaymentsResponse {
  List<PaymentInfo>? items = [];
  double? walletBalance;
  bool? success;
  String? message;
  String? currencyCode;
  String? paymentMethod;
  bool? showAds;
  bool? allowSeatSelection;
  PaymentsResponse({this.items, this.walletBalance, this.success, this.message,
    this.currencyCode, this.paymentMethod, this.showAds, this.allowSeatSelection});

  factory PaymentsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['payments'] as List;
    var walletBalance = json['wallet_balance'];
    return PaymentsResponse(
        items: list.map((p) => PaymentInfo.fromJson(p)).toList(),
        walletBalance: walletBalance != null ? double.parse(walletBalance.toString()) : 0,
        success: json['success'],
        message: json['message'],
        currencyCode: json['currency'],
        paymentMethod: json['payment_method'],
        showAds: json['allow_ads_in_customer_app']!=null? (json['allow_ads_in_customer_app'] == 1 ? true : false) : false,
        allowSeatSelection: json['allow_seat_selection']!=null? (json['allow_seat_selection'] == 1 ? true : false) : false,
    );
  }
}
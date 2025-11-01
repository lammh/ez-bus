
import 'package:intl/intl.dart';

class PaymentInfo{

    int? id;
    String? date;
    double? amount;
    String? paymentMethod;

    PaymentInfo(
        {this.id,
        this.date,
        this.amount,
        this.paymentMethod});

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'payment_date': date,
            'amount': amount,
            'payment_method': paymentMethod,
        };
    }

    static PaymentInfo fromJson(json) {
        return PaymentInfo(
            id: json['id'],
            //date: json['date'],
            amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0,
            paymentMethod: json['payment_method'],
            date: json['payment_date']!=null? DateFormat('yyyy-MM-dd').format(DateTime.parse(json['payment_date']).toLocal()).toString():"",
        );
    }

}

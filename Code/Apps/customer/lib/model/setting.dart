
class Setting{

    String? currencyCode;
    String?  paymentMethod;
    bool? showAds;
    bool? allowSeatSelection;
    Setting({
        this.currencyCode,
        this.paymentMethod,
        this.showAds,
        this.allowSeatSelection,
    });

    Map<String, dynamic> toJson() {
        return {
            'currency_code': currencyCode,
            'payment_method': paymentMethod,
            'allow_ads_in_customer_app': showAds,
            'allow_seat_selection': allowSeatSelection,
        };
    }

    static Setting fromJson(json) {
        return Setting(
            currencyCode: json['currency_code'],
            paymentMethod: json['payment_method'],
            showAds: json['allow_ads_in_customer_app']!=null? (json['allow_ads_in_customer_app'] == 1 ? true : false) : false,
            allowSeatSelection: json['allow_seat_selection']!=null? (json['allow_seat_selection'] == 1 ? true : false) : false,
        );
    }

}

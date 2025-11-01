
class Setting{
  String? currencyCode;
  bool? showAds;

    Setting({
    this.currencyCode,
    this.showAds
    });

    Map<String, dynamic> toJson() {
        return {
            'currency_code': currencyCode,
            'allow_ads_in_driver_app': showAds
        };
    }

    static Setting fromJson(json) {
        return Setting(
            currencyCode: json['currency_code'],
            showAds: json['allow_ads_in_driver_app']!=null? (json['allow_ads_in_driver_app'] == 1 ? true : false) : false,
        );
    }

}

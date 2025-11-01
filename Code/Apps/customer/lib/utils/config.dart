class Config {

  /// -------------------- EDIT THIS WITH YOURS -------------------------------------------------

  // Edit WEB_URL with your url. Make sure you do not add backslash('/') in the end url
  // static String webUrl = "ezbus.creativeapps.info/backend";
  // static String serverUrl = "https://$webUrl";

  static String webUrl = "10.0.2.2/backend";
  static String serverUrl = "http://$webUrl";
  static String socketUrl = "http://213.136.88.215";
  static String socketPort = '6001';

  static String googleApikey = "googleApikey";
  static String systemName = "EzBus";
  static String systemVersion = "1.0.0";
  static String systemCompany = "CreativeApps";
  static String developerInfo = "Developed by $systemCompany";

  static String splashScreenImage1 = "assets/images/splash_1.png";
  static String splashScreenImage2 = "assets/images/splash_2.png";
  static String splashScreenImage3 = "assets/images/splash_3.png";

  static String splashScreenText1 = "A transportation service that is committed to\n enabling cities, individuals, and businesses to move anywhere.\n $systemName is tech-driven, reasonably priced, and convenient.";
  static String splashScreenText2 = "Never be late once more.\n We'll continuously take you there right on the speck with rides moving around the clock.";
  static String splashScreenText3 = "Our main priority is your comfort.\n Let us give you the best service to go wherever and whenever you need to be there.";

  static String shareText = "Let's go anywhere with our smart bus system $systemName! It's simple, easy and secure app.";

  static String credits = "Icons and several images are made by vectorjuice from www.flaticon.com. See more at https://www.freepik.com/author/vectorjuice";


  static var braintreeTokenizationKey = "sandbox_8h4vrhnn_ybjk49xt4kwxmf5s";

  static var razorpayKey = "rzp_test_ijmPq7Vbya4sX1";
  //Public Key
  static var flutterwaveKey="FLWPUBK_TEST-5cb68e5b3515230a9aa660a724fd2985-X";

  static var paytabsProfileId= "89661";
  //Mobile SDK Keys
  static var paytabsServerKey= "S6JN266GWN-JHG92J9TLH-W9TD9BZTZW";
  static var paytabsClientKey= "CGKMQ7-92MD6H-TPM6P7-9BHNKB";/*Mobile SDK Keys*/
  //2 chars iso country code
  static var paytabsMerchantCountryCode= "EG";


  static String androidInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";
  static String iosInterstitialAdUnitId = "ca-app-pub-3940256099942544/4411468910";

}

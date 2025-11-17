class Config {

  static bool localTest = false;
  /// -------------------- EDIT THIS WITH YOURS -------------------------------------------------

  // Edit WEB_URL with your url. Example: yourdomain.com
  static String webUrl = "192.168.31.225:8000";
static String serverUrl = "http://$webUrl";
  static String socketUrl = "http://192.168.31.225";
  static String socketPort = "6001";
  // static String webUrl = "10.0.2.2/backend";
  // static String serverUrl = "http://$webUrl";

  static String googleApikey = "AIzaSyBDEFvG7XTAg-raGqdpl_SjMkCjSzjFVa0";
  static String systemName = "EzBus";
  static String systemVersion = "1.0.0";
  static String systemCompany = "CreativeApps";
  static String developerInfo = "Developed by $systemCompany";

  static String shareText = "Let's go anywhere with our smart bus system $systemName! It's simple, easy and secure app.";


  static var failedText = "Data failure. Please try again later";

  static var noInternetText = "No internet connection";

  static var notAuthenticatedText = "Your account is either disabled or deleted. Please logout and log in again!";

  static var noItem = "No item found";

  static int timeOut = 15;

  static String credits = "Icons and several images are made by vectorjuice from www.flaticon.com. See more at https://www.freepik.com/author/vectorjuice";

  static String androidInterstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";
  static String iosInterstitialAdUnitId = "ca-app-pub-3940256099942544/4411468910";

  static bool mustStartTripWhenCloseToFirstStop = false;
}

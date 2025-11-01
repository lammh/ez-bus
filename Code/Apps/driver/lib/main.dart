import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:ezbusdriver/gui/screens/driver_information_entry_screen.dart';
import 'package:ezbusdriver/gui/screens/driver_under_review_screen.dart';
import 'package:ezbusdriver/gui/screens/wallet_screen.dart';
import 'package:ezbusdriver/utils/config.dart';
import 'package:ezbusdriver/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icon_badge/icon_badge.dart';

import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ezbusdriver/gui/screens/notifications_screen.dart';
import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/utils/size_config.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:ezbusdriver/gui/screens/more_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'gui/languages/language_constants.dart';
import 'gui/screens/home_screen.dart';
import 'gui/screens/running_trip_screen.dart';
import 'gui/screens/sign_in_screen.dart';
import 'gui/widgets/animated_app_bar.dart';
import 'gui/widgets/custom_app_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'gui/widgets/my_interstitial_ad.dart';
import 'model/push_notification.dart';
import 'model/trip.dart';

void showNotification(PushNotification notification) {
  showSimpleNotification(
    Text(
      notification.title!,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.colorSecondary),
    ),
    subtitle: Text(
      notification.body!,
      style: const TextStyle(fontSize: 14, color: AppTheme.darkGrey),
    ),
    background: Colors.white,
    leading: const ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: CircleAvatar(
        backgroundImage: AssetImage("assets/images/notification.png"),
        backgroundColor: AppTheme.lightGrey,
      ),
    ),
    duration: const Duration(seconds: 4),
  );

  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();
  thisAppModel.addNewUnseenNotification(notification);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
/////////////////////////////////////////////////////////////////
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.data["body"]}");
  }

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'ezbus', 'ezbus',
    icon: '@drawable/ic_stat_ic_notification',
    importance: Importance.max,
    priority: Priority.high,
  );


  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.data["title"],
    message.data["body"],
    platformChannelSpecifics,
  );


  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    PushNotification notification = PushNotification(
        title: message.data["title"],
        body: message.data["body"],
        id: message.data["id"]);
    showNotification(notification);
  });
}

////////////////////////////////////////////////////////////////////
Future<void> main() async {
  setupServiceLocator();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ///////////////////////////////////////////////////////////
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  ///////////////////////////////////////////////////////////
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();

  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print("FirebaseMessaging token ${token!}");
  }
  thisAppModel.firebaseToken = token!;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(ScreenUtilInit(
      designSize: const Size(1440/4, 3120/4),
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (context, child) {
        return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: thisAppModel),
            ],
            child: const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: MyApp(),
            ));
      }
    ));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();

  Future<Widget> loadFromFuture() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {
      // Do something
    });
    await thisAppModel.initPlatformState();
    await thisAppModel.isUserLoggedIn();
    await thisAppModel.getDriverDataFromServer();
    // thisAppModel.getUnSeenNotificationsEndpoint();
    return const MainApp();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnimatedSplashScreen.withScreenFunction(
      splash: getSplashScreen(),
      centered: true,
      splashIconSize: SizeConfig.screenHeight,
      screenFunction: () async{
        return loadFromFuture();
      },
    );
  }
}


class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }
  static bool isRtl(BuildContext context){
    return Directionality.of(context)==TextDirection.rtl;
  }
}
class _MainAppState extends State<MainApp> {
// class MainApp extends StatelessWidget {

  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    getLocale().then((locale) {
      setState(() {
        if (kDebugMode) {
          print("locale ${locale.languageCode}");
        }
        _locale = locale;
      });
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Config.systemName,
        theme: customizeAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        home: const MyHomePage(),
      ),
    );
  }

  customizeAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light().copyWith(
        primary: AppTheme.veryLightPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppTheme.lightGrey,
        thickness: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          color: AppTheme.veryLightPrimary,
        ),
        hintStyle: TextStyle(
          color: AppTheme.veryLightPrimary,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.veryLightPrimary,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.veryLightPrimary,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging? _messaging;
  ThisApplicationViewModel thisAppModel =
  serviceLocator<ThisApplicationViewModel>();
  int notificationCounter = 1;

  final List<Widget> _children = [
    const HomeTab(),
    const WalletScreen(),
    const NotificationsScreen(),
    const MoreScreen()
  ];
  final List<IconData> _tabIcons = [
    Icons.account_tree_outlined,
    Icons.credit_card,
    Icons.notifications,
    Icons.menu,
  ];
  PageController? _pageController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    //////////////////////////////////////////////////
    initAndRegisterNotification();
    ////////////////////////////////////////////////////////////////
    _pageController = PageController();
    if (kDebugMode) {
      print("loading ...");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _refreshData();
      });
    });
  }

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.getDriverTripsEndpoint();
          thisAppModel.getNotificationsEndpoint();
          thisAppModel.getPaymentsEndpoint();
          MyInterstitialAd.createInterstitialAd();
        }
    );
  }

  void initAndRegisterNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
          title: message.data["title"],
          body: message.data["body"],
          id: message.data["id"]);
      ThisApplicationViewModel thisAppModel =
      serviceLocator<ThisApplicationViewModel>();

      // For displaying the notification as an overlay
      showNotification(notification);
      // setState(() {
      //   thisAppModel.notificationInfo = notification;
      // });
      showNotificationDialog(context, notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          title: message.data["title"],
          body: message.data["body"],
          id: message.data["id"]
      );

      thisAppModel.isUserLoggedIn().then((_) {
        if (thisAppModel.isLoggedIn!) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        }
      });

      showNotification(notification);
    });
  }

  @override
  Widget build(context) {
    SizeConfig().init(context);

    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        return Consumer<ThisApplicationViewModel>(
          builder: (context, thisApplicationViewModel, child) {
            if (thisApplicationViewModel.isLoggedIn!) {
              for(int i=0; i<thisApplicationViewModel.myTrips.length; i++)
              {
                if(thisApplicationViewModel.myTrips[i].startedAt != null && thisApplicationViewModel.myTrips[i].endedAt == null)
                {
                  Trip trip = thisApplicationViewModel.myTrips[i];
                  return RunningTripScreen(routeId: trip.route!.id!, trip: trip);
                }
              }
              return _buildFirstScreen(context, thisApplicationViewModel);
            }
            else {
              return SignInScreen(widget);
            }
          },
        );
      },
    );
  }

  Widget _buildFirstScreen(
      BuildContext context, ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.currentUser?.statusID == 2) //pending
        {
      return const DriverInformationEntryScreen();
    }
    else if (thisApplicationViewModel.currentUser?.statusID == 4) //under review
        {
      return const DriverUnderReviewScreen();
    }
    else {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: getAppBar(),
          body: SizedBox.expand(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  MyInterstitialAd.showInterstitialAd();
                });
              },
              children: _children,
            ),
          ),
          bottomNavigationBar: Container(
            height: 60.h,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.normalGrey,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                  spreadRadius: 0,
                )
              ],
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 24.h,
                width: 281.w,
                child: Row(
                  children: List.generate(
                      _tabIcons.length,
                          (index) {
                        Widget icon = Icon(
                          _tabIcons[index],
                          color: _currentIndex == index ?
                          AppTheme.darkPrimary :
                          AppTheme.normalGrey,
                        );
                        //check notification count and add badge
                        if (index == 2 && thisApplicationViewModel.unseenNotificationsCount > 0) {
                          icon = IconBadge(
                            icon: Icon(
                              Icons.notifications,
                              color: _currentIndex == index ?
                              AppTheme.darkPrimary :
                              AppTheme.normalGrey,
                            ),
                            itemCount: thisApplicationViewModel.unseenNotificationsCount,
                            badgeColor: Colors.red,
                            itemColor: Colors.white,
                            hideZero: true,
                            right: 20.w,
                          );
                        }
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                                MyInterstitialAd.showInterstitialAd();
                              });
                              _pageController?.jumpToPage(index);
                            },
                            child: icon,
                          ),
                        );
                      }
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  PreferredSizeWidget getAppBar() {
    String? userName = thisAppModel.currentUser != null
        ? (thisAppModel.currentUser!.name!.length > 30
        ? thisAppModel.currentUser!.name!
        .substring(0, thisAppModel.nameTextFieldMaxLength)
        : thisAppModel.currentUser!.name)
        : '';
    if (_currentIndex == 0) {
      return AnimatedAppBar(
        translation(context)?.activeTrips ?? "Active Trips",
        false,
        addPadding: true,
        subTitle: thisAppModel.currentUser != null ? "Hi, ${userName!}" : null,
      );
    } else if (_currentIndex == 1) {
      return AnimatedAppBar(translation(context)?.wallet ?? "Wallet", false);
    } else if (_currentIndex == 2) {
      return AnimatedAppBar(translation(context)?.notifications ?? "Notifications", false);
    } else {
      return const CustomAppBar();
    }
  }
}



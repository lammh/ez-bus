
import 'package:ezbus/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/main.dart';
import 'package:ezbus/utils/size_config.dart';
import 'package:ezbus/gui/widgets/splash_content.dart';
import 'package:ezbus/gui/widgets/default_button.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/utils/tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../languages/language_constants.dart';

class LandingPagesScreen extends StatelessWidget {

  static String routeName = "/splash";

  const LandingPagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
          constraints: const BoxConstraints.expand(),
          child: _Body()),
    );
  }
}

class _Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool donotShow = false;
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": Config.splashScreenText1,
      "image": Config.splashScreenImage1
    },
    {
      "text": Config.splashScreenText2,
      "image": Config.splashScreenImage2
    },
    {
      "text": Config.splashScreenText3,
      "image": Config.splashScreenImage3
    },
  ];

  @override
  void initState() {
    super.initState();

    Tools.getDonotShow().then((value) =>
    {
      donotShow = value
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                            (index) => buildDot(index: index),
                      ),
                    ),
                    const Spacer(),
                    DefaultButton(
                      text: "Continue",
                      press: () {
                        saveDonotShow(donotShow);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MyHomePage()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                    SizedBox(height: 20.h,),
                    Row(
                      children: [
                        Checkbox(
                          value: donotShow,
                          activeColor: AppTheme.primary,
                          onChanged: (value) {
                            setState(() {
                              donotShow = value!;
                            });
                          },
                        ),
                        Text(translation(context)?.doNotShowTip ?? "Don't show tips again"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  saveDonotShow(bool d) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('donotShow', d);
  }



  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5.w),
      height: 6.h,
      width: currentPage == index ? 20.w : 6.w,
      decoration: BoxDecoration(
        color: currentPage == index ? AppTheme.primary : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
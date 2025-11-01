import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//App colors and theme
class AppTheme {



  AppTheme._();

  static const Color veryLightPrimary = Color.fromARGB(255, 145, 178, 250);
  static const Color lightPrimary = Color(0x7F2C1FBC);
  static const Color primary = Color(0xFF2C1FBC);
  static const Color darkPrimary = Color(0xFF1A0F91);

  static const Color colorSecondary = Color(0xFFf00000);
  static const Color lightColorSecondary = Color(0xFFFE7C71);

  static const Color backgroundColor = Colors.white;

  static const Color veryLightGrey = Color(0xFFf7f7f7);
  static const Color lightGrey = Color(0xFFe6e6e6);
  static const Color normalGrey= Color(0xFF8E8E8E);
  static const Color darkGrey = Color(0xFF263238);

  static const String fontName = "Kreon";


  static const TextStyle menuItem = TextStyle( // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    letterSpacing: 0.4,
    height: 0.9,
    color: Colors.black,
  );

  static TextStyle headlineBig = const TextStyle(
    color: primary,
    fontSize: 35,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textGreySmall = const TextStyle(
    color: AppTheme.normalGrey,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w400,
  );
  static TextStyle textPrimarySmallBold = const TextStyle(
    color: AppTheme.primary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textGreyMedium = const TextStyle(
    color: AppTheme.normalGrey,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textGreyLarge = const TextStyle(
    color: AppTheme.normalGrey,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textWhiteSmall = const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w400,
  );

  static TextStyle textWhiteMedium = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );


  static TextStyle textWhiteLarge = const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkBlueSmall = const TextStyle(
    color: AppTheme.primary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textDarkBlueSmallLight = const TextStyle(
    color: AppTheme.primary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w400,
  );

  static TextStyle textDarkBlueMedium = const TextStyle(
    color: AppTheme.primary,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkBlueLarge = const TextStyle(
    color: AppTheme.primary,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textDarkBlueXL = const TextStyle(
    color: AppTheme.primary,
    fontSize: 24,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textdarkPrimaryLarge = const TextStyle(
    color: AppTheme.darkPrimary,
    fontSize: 20,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textdarkPrimaryXL = const TextStyle(
    color: AppTheme.darkPrimary,
    fontSize: 38,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );
  static TextStyle textlightPrimaryMedium = const TextStyle(
    color: AppTheme.lightPrimary,
    fontSize: 16,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle textSecondaryMedium = const TextStyle(
    color: AppTheme.lightPrimary,
    fontSize: 14,
    fontFamily: 'Open Sans',
    fontWeight: FontWeight.w700,
  );

  static TextStyle bold24Grey90 =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: AppTheme.darkGrey,
  ));

  static TextStyle bold20Grey40 =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AppTheme.normalGrey,
    ));


  static TextStyle menu =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontSize: 18,
        color: AppTheme.darkPrimary,
      ));

  static TextStyle bold20Black =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ));

  static TextStyle bold14Grey60 =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: 0.27,
    color: AppTheme.normalGrey,
  ));

  static TextStyle normal14Grey40 =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontSize: 14,
        letterSpacing: 0.27,
        color: AppTheme.normalGrey,
      ));

  static TextStyle normal14Grey20 =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontSize: 14,
        letterSpacing: 0.27,
        color: AppTheme.lightGrey,
      ));

  static TextStyle bold16Black =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.27,
        color: Colors.black,
      ));


  static TextStyle bold14Black =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.27,
        color: Colors.black,
      ));

  static TextStyle bold14DarkBlue =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.27,
        color: AppTheme.primary,
      ));

  static TextStyle bold14Grey20 =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontSize: 14,
        letterSpacing: 0.27,
        color: AppTheme.lightGrey,
      ));

  static TextStyle title =
  GoogleFonts.getFont('Open Sans',
    textStyle:const TextStyle(
      color: AppTheme.primary,
      fontSize: 24,
  fontFamily: 'Open Sans',
  fontWeight: FontWeight.w700,
  ),);

  static TextStyle bold20DarkBlue =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: AppTheme.primary,
        height: 1.5,
      ));

  static TextStyle bold20Primary =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    letterSpacing: 0.18,
    color: AppTheme.primary,
  ));

  static TextStyle bold18Green =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    letterSpacing: 0.18,
    color: Colors.green,
  ));


  static TextStyle bold14Secondary =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.18,
        color: colorSecondary,
      ));

  static TextStyle bold16Secondary =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.18,
        color: colorSecondary,
      ));

  static TextStyle coloredGreenSubTitle =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontSize: 14,
        letterSpacing: 0.18,
        color: Colors.green,
      ));

  static const TextStyle coloredRedTitle = TextStyle( // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    letterSpacing: 0.18,
    color: AppTheme.colorSecondary,
  );

  static const TextStyle coloredRedTitle2 = TextStyle( // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppTheme.colorSecondary,
  );

  static TextStyle subtitle =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 13,
    color: Colors.black,
      //line spacing
      height: 2.0,
  ));

  static const TextStyle coloredSubtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: Colors.black,
  );


  static const TextStyle redColoredSubtitle = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 13,
    color: AppTheme.colorSecondary,
  );

  static const TextStyle subtitle2 = TextStyle( // subtitle2 -> subtitle
    fontFamily: fontName,
    fontSize: 12,
    letterSpacing: -0.04,
    color: darkGrey,
  );


  static const TextStyle paragraph = TextStyle( // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: Colors.black,
  );


  static TextStyle caption =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0.2,
        color: darkGrey, // was colorAccent
      ));

  static TextStyle captionGray =
  GoogleFonts.getFont('Open Sans',
      textStyle:const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12,
        letterSpacing: 0.2,
        color: normalGrey, // was colorAccent
      ));


  static const TextStyle captionWhite = TextStyle( // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    letterSpacing: 0.2,
    color: Colors.white, // was colorAccent
  );

  static const TextStyle subCaptionSecondary = TextStyle( // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.2,
    color: colorSecondary, // was colorAccent
  );

  static const TextStyle subCaption2 = TextStyle( // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: darkGrey, // was colorAccent
  );

  static const appBarTextTheme = TextTheme(

    titleLarge: TextStyle(
      color:Colors.black,
      fontSize: 20.0,
    ),
  );

  // Form Error
  static final RegExp emailValidatorRegExp =
  RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static final RegExp phoneNumberValidatorRegExp = RegExp(r"^(?:[+0]9)?[0-9]{10}$");
  static const String kEmailNullError = "Please enter your email";
  static const String kInvalidEmailError = "Please enter a valid Email";
  static const String kPassNullError = "Please enter your password";
  static const String kConfirmPassNullError = "Please confirm your password";
  static const String kShortPassError = "Password is too short";
  static const String kMatchPassError = "Passwords don't match";
  static const String kNameNullError = "Please enter your user name";
  static const String kPhoneNumberNullError = "Please enter your phone number";
  static const String kInvalidPhoneNumberError = "Please enter a valid phone number";
  static const String kAddressNullError = "Please enter your address";
  static const String kIterestsNullError = "Please enter your interests";

  static const String kNumberNullError = "Please enter a number";
  static const String kInvalidNumberError = "Please enter a valid number";

  static List countries = ["CA", "PUW", "JFK", "NYL", "LAS"];


}




import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/services/system_chrome.dart';

class AppTheme {
  static SystemUiOverlayStyle overlayStyleDefault =
      SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: AppColors.white,
    statusBarColor: Colors.transparent,
  );

  static SystemUiOverlayStyle overlayStyleGallery =
      SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: AppColors.black,
    statusBarColor: Colors.transparent,
  );

  static SystemUiOverlayStyle overlayStyleLogin =
      SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: AppColors.white,
    statusBarColor: Colors.transparent,
  );

  static SystemUiOverlayStyle overlayStyleBottomTabBar =
      SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarColor: AppColors.bottomNaveBarColor,
    statusBarColor: Colors.transparent,
  );

  static splitBorderForSelector(bool isCorner) => BorderRadius.only(
        topLeft: Radius.circular(
            (isCorner ? AppDimensions.selectorFieldRadius : 0.0)),
        bottomLeft: Radius.circular(
            (isCorner ? AppDimensions.selectorFieldRadius : 0.0)),
        topRight: Radius.circular(
            (!isCorner ? AppDimensions.selectorFieldRadius : 0.0)),
        bottomRight: Radius.circular(
            (!isCorner ? AppDimensions.selectorFieldRadius : 0.0)),
      );

  static splitBorderForTextFields(bool isCorner) => BorderRadius.only(
        topLeft:
            Radius.circular((isCorner ? AppDimensions.textFieldRadius : 0.0)),
        bottomLeft:
            Radius.circular((isCorner ? AppDimensions.textFieldRadius : 0.0)),
        topRight:
            Radius.circular((!isCorner ? AppDimensions.textFieldRadius : 0.0)),
        bottomRight:
            Radius.circular((!isCorner ? AppDimensions.textFieldRadius : 0.0)),
      );

  static ThemeData getThemeData(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.colorPrimary,
      primaryColorDark: AppColors.colorPrimaryDark,
      accentColor: AppColors.colorAccent,
      brightness: Brightness.light,
      backgroundColor: AppColors.bgColor,
      fontFamily: 'Custom',
      buttonColor: AppColors.buttonColor,
      iconTheme: IconThemeData(color: AppColors.colorAccent),
      focusColor: AppColors.colorAccent,
      highlightColor: AppColors.colorAccent,
      dividerColor: AppColors.listSeparator,
      dividerTheme: DividerThemeData(
        color: AppColors.listSeparator,
        thickness: 1,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.colorAccent),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        shape: new RoundedRectangleBorder(
            borderRadius:
            new BorderRadius.circular(AppDimensions.buttonRadius)),
        primary: AppColors.buttonColor,
        onPrimary: AppColors.white,
        elevation: 5.0,
        padding: EdgeInsets.only(left: AppDimensions.maxPadding,
            right: AppDimensions.maxPadding,
            top: AppDimensions.generalPadding,
            bottom: AppDimensions.generalPadding),
      ),),
      buttonTheme: ButtonThemeData(
          shape: new RoundedRectangleBorder(
              borderRadius:
                  new BorderRadius.circular(AppDimensions.buttonRadius)),
          buttonColor: AppColors.buttonColor,
          textTheme: ButtonTextTheme.primary),
      textTheme: TextTheme(
          headline3: TextStyle(
            color: AppColors.textColor,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          headline4: TextStyle(
            color: AppColors.textColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          headline5: TextStyle(
            color: AppColors.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          headline6: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          subtitle1: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          subtitle2: TextStyle(color: AppColors.textColor, fontSize: 15, fontWeight: FontWeight.w400,),
            bodyText1: TextStyle(color: AppColors.textColor, fontSize: 14, fontWeight: FontWeight.w700,),
            bodyText2: TextStyle(color: AppColors.textColor, fontSize: 14, fontWeight: FontWeight.w400,),
            caption: TextStyle(color: AppColors.textColor, fontSize: 12, fontWeight: FontWeight.w700,),
            overline: TextStyle(color: AppColors.textColor, fontSize: 10, fontWeight: FontWeight.w500,),
            button: TextStyle(color: AppColors.buttonColor, fontSize: 18, fontWeight: FontWeight.w600,)
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.only(left: 20.0, right: 5.0, top: 16.0, bottom: 16.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.textFieldRadius)),
              borderSide: BorderSide(width: 2, color: AppColors.colorAccent)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.textFieldRadius)),
              borderSide: BorderSide(width: 2, color: AppColors.colorAccent)),
          focusColor: AppColors.colorAccent,
          fillColor: AppColors.white,
          filled: true,
        ),
        appBarTheme: AppBarTheme(
            color: AppColors.white,
            iconTheme: IconThemeData(color: AppColors.black),
            textTheme: TextTheme(
                headline6: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black, fontFamily: 'Custom', fontWeight: FontWeight.w600)
            ),
            elevation: 0,
        ),
        cardTheme: CardTheme(
            elevation: AppDimensions.card_elevation,
            shape:  RoundedRectangleBorder(
              borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
            ),
            clipBehavior: Clip.hardEdge
        ),
    );
  }

  static InputDecoration inputDecorationThemeForSearch({String searchHint = AppStrings.searchHint}){
    return InputDecoration(hintText: searchHint,
      contentPadding: EdgeInsets.only(left: 20.0, right: 5.0, top: 0.0, bottom: 0.0),
      hintStyle: TextStyle(color: AppColors.grayColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(width: 0.5, color: AppColors.backgroundGrey300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50)), borderSide: BorderSide(width: 0.5, color: AppColors.backgroundGrey300)),
      focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50)), borderSide: BorderSide(width: 0.5, color: AppColors.backgroundGrey300)),
      fillColor: AppColors.backgroundGrey300,
      filled: true,
    );
  }

  static const gradientDecorationForSliver = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.white,
    ],
  );

}

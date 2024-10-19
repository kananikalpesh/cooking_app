
import 'dart:async';

import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/modules/login/landing/LandingScreen.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';

const _TAG = "LauncherScreen";
class LauncherScreen extends StatefulWidget {
  LauncherScreen({Key key}) : super(key: key);

  @override
  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {

  ValueNotifier<bool> _isError = ValueNotifier(false);
  String _error = "";
  String _firebaseToken;

  @override
  void initState() {
    super.initState();

    _firebaseNotificationSetup();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleLogin);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/login_background.jpg"), fit: BoxFit.fill
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.maxPadding),
          child: Column(
            children: <Widget>[
              SizedBox(height: AppDimensions.maxPadding,),
              Image.asset("assets/app_logo.png", height: AppDimensions.loginScreensLogoSize,),
              SizedBox(height: AppDimensions.largeTopBottomPadding,),
              ValueListenableProvider<bool>.value(
                value: _isError,
                child: Consumer<bool>(
                  builder: (context, isGotError, child){
                    return isGotError ? Column(
                      children: [
                        Text(_error, style: Theme.of(context).textTheme.bodyText1.copyWith(fontStyle: FontStyle.italic,
                            color: AppColors.errorTextColor),),
                        SizedBox(height: AppDimensions.generalPadding,),
                        ElevatedButton(
                          onPressed: (){
                            _isError.value = false;
                          },
                          child: Text(AppStrings.retryLabel,),
                        ),
                      ],
                    ) : CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _firebaseNotificationSetup() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _firebaseToken = await _firebaseMessaging.getToken();
    await SharedPreferenceManager().setFirebaseToken(_firebaseToken);
    LogManager()
        .log(_TAG, "_firebaseNotificationSetup", "Getting firebase token.");

    _proceedFromSplash();
  }

  _proceedFromSplash() async{
    bool _isLoggedIn = await SharedPreferenceManager().isLoggedIn();
    if (_isLoggedIn) AppData.user = await SharedPreferenceManager().getUser();
    Future.delayed(Duration(seconds: 3),() async {
      if (_isLoggedIn){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LandingScreen()));
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

}

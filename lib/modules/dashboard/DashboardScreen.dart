
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/main.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/constants/ConCubeConstants.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/admin/all_users/AllUsersScreen.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsScreen.dart';
import 'package:cooking_app/modules/admin/payments/AllPaymentsScreen.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/cook/lesson/my_lessons/MyLessonsScreen.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileBloc.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileScreen.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/ManageAvailabilitiesScreen.dart';
import 'package:cooking_app/modules/cook/profile/edit_profile/EditProfileScreen.dart';
import 'package:cooking_app/modules/dashboard/ConnectStripeBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/DashboardBloc.dart';
import 'package:cooking_app/modules/dashboard/HomeNavigationsScreen.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsScreen.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestScreen.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsScreens.dart';
import 'package:cooking_app/modules/stripe_payment/OnboardingModel.dart';
import 'package:cooking_app/modules/stripe_payment/StripeOnboardingScreen.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/modules/user/profile/UserProfileScreen.dart';
import 'package:cooking_app/modules/video_chat/IncomingCallScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {

  if (Platform.isAndroid) {
    if (message.data.containsKey(ConCubeConstants.CC_NOTIFICATION_TYPE)) {
      const int insistentFlag = 4;
      AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'CC_Call',
        'Call Notifications',
        'Receive Notification for audio and video call',
        playSound: true,
        importance: Importance.max,
        priority: Priority.max,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        timeoutAfter: 50000,
        ongoing: true,
        additionalFlags: Int32List.fromList(<int>[insistentFlag]),
        sound: RawResourceAndroidNotificationSound('sample_ringtone'),
      );
      const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(sound: 'sample_ringtone.mp3');
      const MacOSNotificationDetails macOSPlatformChannelSpecifics =
      MacOSNotificationDetails(sound: 'sample_ringtone.mp3');
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
          macOS: macOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          DateTime.now().microsecond,
          '${message.data[ConCubeConstants.CC_CALL_TYPE_STRING]}',
          '${message.data[ConCubeConstants.CC_CALL_MESSAGE]}',
          platformChannelSpecifics,
          payload: jsonEncode(message.data));
    }
  }

  return Future.value();
}

class DashboardScreen extends StatefulWidget {
  final int selectedTabIndex;
  DashboardScreen({this.selectedTabIndex = AppConstants.DASHBOARD_LESSONS});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String TAG = "_DashboardScreenState";

  GlobalKey _bottomNavigationKey = GlobalKey();
  ValueNotifier<int> _selectedBottomNavigationIndex;
  ValueNotifier<String> _appBartTitle =
  ValueNotifier(AppStrings.dashboardHomeTitle);
  ValueNotifier<bool> _showDashboardContent = ValueNotifier(false);
  DashboardBloc _bloc;
  CookProfileBloc _cookBloc;
  bool _isStripeOnBoardingShown = false;

  @override
  initState() {
    _selectedBottomNavigationIndex = ValueNotifier(widget.selectedTabIndex);

    _bloc = DashboardBloc();

    _connectyCubeSetup();

    _cookBloc = CookProfileBloc();

    _cookBloc.obsGetUserProfile.stream.listen((result) async {
      if (result.error == null) {
        AppData.user = result.data;
        if ((AppData.user.aboutMe?.isEmpty ?? true) || (AppData.user.cooksCuisines?.isEmpty ?? true)) {

          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(AppData.user, _cookBloc, isInComplete: true),
            ),
          ).then((value){
            _selectedBottomNavigationIndex.value = AppConstants.DASHBOARD_LESSONS;
          });
        } else if (AppData.user.cookAvailabilities?.isEmpty ?? true) {

          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => ManageAvailabilitiesScreen(isInComplete: true),
            ),
          );
        } else { //check pgStatus
          if(AppData.user.pgStatus.block == true){

            ResultModel<OnboardingModel> result = await ConnectStripeBottomSheet.connectStripSheet(context, _cookBloc);
              ///Handling result after connectStripSheet returns result.
            if(!_isStripeOnBoardingShown && result != null){
                _handleOnBoardingResult(result);
            }
          }
        }
      }
      _showDashboardContent.value = true;
      if(AppData.user.role == AppConstants.ROLE_COOK){
      _bloc.updateCookDashBoardBottomBar.value = (!_bloc.updateCookDashBoardBottomBar.value);
      }
    });

    if (AppData.user.role == AppConstants.ROLE_COOK)
      _cookBloc.event.add(EventModel(
          CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
    else _showDashboardContent.value = true;

    super.initState();
    _setupHandleNotification();

    SharedPreferenceManager().getFirebaseToken().then((value){
      if(value != null){

        _bloc.event.sink.add(
            EventModel(DashboardBloc.SEND_DEVICE_DATA_EVENT, data: value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);

    AppData.appContext = context;
    return ValueListenableProvider<bool>.value(
      value: _showDashboardContent,
      child: Consumer<bool>(
        builder: (context, showContent, child){
          return (showContent) ? Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            //drawer: DashboardDrawerWidget(() {}),
            body: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.maxPadding),
              child: ValueListenableProvider<int>.value(
                value: _selectedBottomNavigationIndex,
                child: Consumer<int>(
                  // ignore: missing_return
                  builder: (context, value, child) {
                    return (AppData.user.role == AppConstants.ROLE_ADMIN) ? _getAdminScreens(value) : _getScreens(value);
                  },
                ),
              ),
            ),
            bottomNavigationBar: ValueListenableProvider<bool>.value(
              value: _bloc.updateCookDashBoardBottomBar,
              child: Consumer<bool>(builder: (context, value, child){
                return SizedBox(
                  height: (50.0 + MediaQuery.of(context).padding.bottom),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom),
                          child: CurvedNavigationBar(
                            key: _bottomNavigationKey,
                            index: widget.selectedTabIndex,
                            height: 50.0,
                            items: (AppData.user.role == AppConstants.ROLE_ADMIN) ? _getAdminBottomBarItems() : _getBottomBarItems(),
                            color: AppColors.bottomNaveBarColor,
                            buttonBackgroundColor: Theme.of(context).backgroundColor,
                            backgroundColor: Colors.transparent,
                            animationCurve: Curves.easeInOutCirc,
                            animationDuration: Duration(milliseconds: 600),
                            onTap: (index) {
                              setState(() {
                                _selectedBottomNavigationIndex.value = index;
                                (AppData.user.role == AppConstants.ROLE_ADMIN) ? _setAdminAppbarTitle(index) : _setAppbarTitle(index);
                              });
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(context).padding.bottom,
                          color: AppColors.bottomNaveBarColor,
                        ),
                      )
                    ],
                  ),
                );
              }),),
          )
              : Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );


  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProfileIcon(){
    String icon = "assets/dashboard_cook_profile.png";

    if(AppData.user.role == AppConstants.ROLE_COOK){
      if((AppData.pgStatus?.block ?? false) == false && (AppData.pgStatus?.flashMessage ?? false) == true){
        icon =  "assets/dashboard_cook_profile_notification.png";
      }
    }

    return icon;
  }

  // ignore: missing_return
  Widget _getScreens(int value){
    switch (value) {
      case AppConstants.DASHBOARD_LESSONS:
        return (AppData.user.role == AppConstants.ROLE_COOK) ? MyLessonsScreen(_bloc) : HomeNavigationScreen();
        break;
      case AppConstants.DASHBOARD_BOOKINGS:
        return MyBookingsScreen();
        break;
      case AppConstants.DASHBOARD_PROFILE:
        return (AppData.user.role == AppConstants.ROLE_COOK) ? CookProfileScreen(_bloc)
            : UserProfileScreen();
        break;
    }
  }

  List<Widget> _getBottomBarItems(){
    return <Widget>[
      Image.asset("assets/dashboard_lesson.png",
        width: AppDimensions.generalIconSize,
        height: AppDimensions.generalIconSize,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_LESSONS)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
      Image.asset(
        "assets/dashboard_booking.png",
        width: AppDimensions.generalIconSize,
        height: AppDimensions.generalIconSize,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_BOOKINGS)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
      Image.asset(_getProfileIcon(),
        width: AppDimensions.generalIconSize,
        height: AppDimensions.generalIconSize,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_PROFILE)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
    ];
  }

  _setAppbarTitle(int index){
    switch (index) {
      case AppConstants.DASHBOARD_LESSONS:
        _appBartTitle.value = (AppData.user.role == AppConstants.ROLE_COOK) ? AppStrings.myLessonsTitle : AppStrings.dashboardLessonTitle;
        break;
      case AppConstants.DASHBOARD_BOOKINGS:
        _appBartTitle.value = AppStrings.dashboardBookingTitle;
        break;
      case AppConstants.DASHBOARD_PROFILE:
        _appBartTitle.value = AppStrings.dashboardProfileTitle;
        break;
    }
  }

  // ignore: missing_return
  Widget _getAdminScreens(int value){
    switch (value) {
      case AppConstants.DASHBOARD_ADMIN_ANALYTICS:
        return AnalyticsScreen();
        break;
      case AppConstants.DASHBOARD_ADMIN_FLAGGED_USERS:
        return AllUsersScreen(GlobalKey(), true);
        break;
      case AppConstants.DASHBOARD_ADMIN_ALL_USERS:
        return AllUsersScreen(GlobalKey(), false);
        break;
      case AppConstants.DASHBOARD_ADMIN_PAYMENTS:
        return AllPaymentsScreen();
        break;
      case AppConstants.DASHBOARD_ADMIN_PROFILE:
        return UserProfileScreen();
        break;
    }
  }

  List<Widget> _getAdminBottomBarItems(){
    return <Widget>[
      Image.asset("assets/dashboard_analytics.png",
        width: 25,
        height: 25,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_ADMIN_ANALYTICS)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
      Image.asset("assets/dashboard_flagged_users.png",
        width: 22,
        height: 22,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_ADMIN_FLAGGED_USERS)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
      Image.asset("assets/dashboard_all_users.png",
        width: 25,
        height: 25,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_ADMIN_ALL_USERS)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
      Image.asset("assets/dashboard_payments.png",
        width: AppDimensions.generalIconSize,
        height: AppDimensions.generalIconSize,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_ADMIN_PAYMENTS)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
      Image.asset("assets/dashboard_cook_profile.png",
        width: AppDimensions.generalIconSize,
        height: AppDimensions.generalIconSize,
        color: (_selectedBottomNavigationIndex.value == AppConstants.DASHBOARD_ADMIN_PROFILE)
            ? Theme.of(context).accentColor
            : Theme.of(context).backgroundColor,
      ),
    ];
  }

  _setAdminAppbarTitle(int index){
    switch (index) {
      case AppConstants.DASHBOARD_ADMIN_ANALYTICS:
        _appBartTitle.value = AppStrings.analytics;
        break;
      case AppConstants.DASHBOARD_ADMIN_FLAGGED_USERS:
        _appBartTitle.value = AppStrings.flaggedUsers;
        break;
      case AppConstants.DASHBOARD_ADMIN_ALL_USERS:
        _appBartTitle.value = AppStrings.allUsers;
        break;
      case AppConstants.DASHBOARD_ADMIN_PAYMENTS:
        _appBartTitle.value = AppStrings.payments;
        break;
      case AppConstants.DASHBOARD_ADMIN_PROFILE:
        _appBartTitle.value = AppStrings.dashboardProfileTitle;
        break;
    }
  }

  _handleOnBoardingResult(ResultModel<OnboardingModel> result) async {

    if (result.error != null) {
      CommonBottomSheet.showErrorBottomSheet(context, result);
    } else {
      var paymentModel = result.data;

      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
      var response = await Navigator.of(context)
          .push(MaterialPageRoute(
          builder: (context) => StripeOnboardingScreen(url: paymentModel.link,
            refreshUrl: paymentModel.refreshUrl, returnUrl: paymentModel.returnUrl,)));
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);

       if (response != null && !(response is bool)){
        //Failed
        CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: AppStrings.accFailedDesc,),
          title: AppStrings.accFailedTitle,);
      }

      _isStripeOnBoardingShown = true;
      _cookBloc.event.add(EventModel(
          CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
    }

  }

  _connectyCubeSetup(){
    _initCustomMediaConfigs();
    if (AppData.cubeUser != null) {
      _initCalls();
    }else{
      _setupCalls();
    }
  }

  void _initCustomMediaConfigs() {
    RTCMediaConfig mediaConfig = RTCMediaConfig.instance;
    mediaConfig.minHeight = 720;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;
  }

  void _setupCalls() async{
    var user = AppData.user;
    if (user != null && user.ccId != null) {
      var cubeUser = ConCubeUtils.getCubeUserObject(user, ccId: user.ccId);
      await ConCubeUtils.createSessionAndLogin(cubeUser, forceCreateSession: true);
      if(AppData.cubeUser != null){
        _initCalls();
      }
    }
  }

  void _initCalls() {

    AppData.callClient.onReceiveNewSession = (callSession) {
      if (AppData.currentCall != null &&
          AppData.currentCall.sessionId != callSession.sessionId) {
        callSession.reject();
        return;
      }

      _showIncomingCallScreen(callSession);
    };

    AppData.callClient.onSessionClosed = (callSession) {
      if (AppData.currentCall != null && AppData.currentCall.sessionId == callSession.sessionId) {
        AppData.currentCall = null;
      }
      if (AppData?.callKitCurrentCallId?.isEmpty == false) {
        AppData.callKit?.endCall(AppData?.callKitCurrentCallId);
      }
    };

    _subscribeForCCNotification();
  }

  _setupHandleNotification() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showForegroundAppNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      ///When clicked notification and app came to foreground from background.
      _handleNavigation(event);
    });

    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        ///When clicked notification and app started form terminated state.
        _handleNavigation(event);
      }
    });

    LogManager().log(
        TAG, "_setupHandleNotification", 'Calling _subscribeForCCNotification');
  }

  _handleNavigation(RemoteMessage event){

    if (!event.data.containsKey(ConCubeConstants.CC_NOTIFICATION_TYPE)){
      if(int.parse(event.data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_LESSON_DETAIL){
          int lessonId = int.parse(event.data[AppConstants.LESSON_ID]);
          int cookId = int.parse(event.data[AppConstants.COOK_ID]);
          int lessonBookingId = int.parse(event.data[AppConstants.BOOKING_ID]);
          bool isFromCook = (AppData.user.role == AppConstants.ROLE_COOK);

          Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
          Navigator.of(AppData.appContext).push(MaterialPageRoute(
              builder: (context) => LessonDetailsScreen(cookId: cookId, id: lessonId, isFromCook: isFromCook, lessonBookingId: lessonBookingId,)));
      }else if(int.parse(event.data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_BOOKINGS_REQ_LIST){
        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        Navigator.of(AppData.appContext).push(MaterialPageRoute(
            builder: (context) => MyRequestScreen()));
      } else if(int.parse(event.data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_BOOKINGS_LIST){
        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        _selectedBottomNavigationIndex.value = AppConstants.DASHBOARD_BOOKINGS;
      }else if(int.parse(event.data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_REVIEWS_LIST){
        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        _selectedBottomNavigationIndex.value = AppConstants.DASHBOARD_PROFILE;
        Navigator.of(AppData.appContext).push(MaterialPageRoute(
            builder: (context) => UserReviewsScreens(AppData.user.id, AppData.user.firstName, isCook: (AppData.user.role == AppConstants.ROLE_COOK),)));
      }else{
        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        _selectedBottomNavigationIndex.value = AppConstants.DASHBOARD_BOOKINGS;
      }
    }
  }

  showForegroundAppNotification(RemoteMessage message) async {
    String channelId;
    String channelName;
    String channelDescription;

    channelId = AppConstants.GENERAL_NOTIFICATION_CHANNEL_ID;
    channelName = AppConstants.GENERAL_NOTIFICATION_CHANNEL_NAME;
    channelDescription = AppConstants.GENERAL_NOTIFICATION_CHANNEL_DESCRIPTION;

    if (!message.data.containsKey(ConCubeConstants.CC_NOTIFICATION_TYPE)){

      AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription,
        channelShowBadge: true,
        importance: Importance.max,
        priority: Priority.max,
        visibility: NotificationVisibility.public,
        enableVibration: true,
      );
      const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails();
      const MacOSNotificationDetails macOSPlatformChannelSpecifics =
      MacOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
          macOS: macOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          DateTime.now().microsecond,
          '${message.notification?.title ?? ""}',
          '${message.notification?.body ?? ""}',
          platformChannelSpecifics,
          payload: jsonEncode(message.data)).catchError((e){
        LogManager().log(TAG, "showForegroundAppNotification", "Error while show notification", e: e);
      });
    }


  }

  void _showIncomingCallScreen(P2PSession callSession) {
    Navigator.push(
      AppData.appContext,
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(callSession),
      ),
    );
  }

  _subscribeForCCNotification() async {
    String token = await SharedPreferenceManager().getFirebaseToken();

    String voipToken = "";
    if (Platform.isIOS) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      voipToken = await MethodChannel('${packageInfo.packageName}/voip')
          .invokeMethod('getVoipToken');

      if (voipToken?.isEmpty ?? true) {
        voipToken = await SharedPreferenceManager().getVoIPToken();
      } else {
        SharedPreferenceManager().setVoIPToken(voipToken);
      }
    }

    CreateSubscriptionParameters parameters = CreateSubscriptionParameters();
    parameters.environment = AppData.isProduction
        ? CubeEnvironment.PRODUCTION
        : CubeEnvironment.DEVELOPMENT;

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      parameters.channel = NotificationsChannels.GCM;
      parameters.platform = CubePlatform.ANDROID;
      parameters.bundleIdentifier =
          packageInfo.packageName;
      parameters.udid = build.androidId;
      parameters.pushToken = token;
    } else if (Platform.isIOS) {
      var build = await deviceInfoPlugin.iosInfo;
      parameters.channel = NotificationsChannels.APNS_VOIP;
      parameters.platform = CubePlatform.IOS;
      parameters.bundleIdentifier =
          packageInfo.packageName;
      parameters.udid = build.identifierForVendor.isNotEmpty ? build.identifierForVendor : voipToken;
      parameters.pushToken = voipToken;
    }
    LogManager().log(
        TAG, "_subscribeForCCNotification", 'Calling createSubscription');

    createSubscription(parameters.getRequestParameters())
        .then((cubeSubscription) {
      if ((cubeSubscription?.length ?? 0) > 0) {
        SharedPreferenceManager().setCCSubscriptionId(cubeSubscription[0].id);
      }
      LogManager().log(TAG, "_subscribeForCCNotification",
          "After calling createSubscription for subscribe for CC notification");
    }).catchError((error) {
      LogManager().log(TAG, "_subscribeForCCNotification",
          "Error while calling createSubscription for subscribe for CC notification",
          e: error);
    });
  }

}

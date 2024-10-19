import 'dart:convert';
import 'dart:io';

import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/constants/ConCubeConstants.dart';
import 'package:cooking_app/model/custom_objects/ReceivedNotification.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/modules/launcher/LauncherScreen.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestScreen.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsScreens.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/modules/video_chat/IncomingCallScreen.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_call_kit/flutter_call_kit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_voip_push_notification/flutter_voip_push_notification.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

import 'model/constants/AppConstants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

String selectedNotificationPayload;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{

  bool _initialized = false;
  bool _error = false;
  String initialRoute = "/LauncherScreen";

  FlutterVoipPushNotification _voipPush = FlutterVoipPushNotification();

  @override
  void initState() {

    if (Platform.isIOS) {
      AppData.callKit = FlutterCallKit();
      _configureCallKit();
    }

    initializeFlutterFire();

    _localNotificationSetup();

    super.initState();
    LogManager().setup();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    init(
      ConCubeConstants.APP_ID,
      ConCubeConstants.AUTH_KEY,
      ConCubeConstants.AUTH_SECRET,
    );

    if (Platform.isAndroid) {
      _configureSelectNotificationSubject();
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {

    if (_error) {
      return _errorWidget();
    }

    if (!_initialized) {
      return _loadingWidget();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.getThemeData(context),
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        '/LauncherScreen': (BuildContext context) => LauncherScreen(),
        '/IncomingCallScreen': (BuildContext context) => IncomingCallScreen(
            null,
            selectedNotificationPayload: selectedNotificationPayload),
        'DashboardScreen':(BuildContext context) => DashboardScreen()
      },
    );
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      setState(() {
        _error = true;
      });
    }
  }

  Widget _errorWidget() {
    return Center(
      child: Text(AppStrings.generalTechError, style: TextStyle(fontSize: 16),),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _configureCallKit() async {
    AppData.callKit.configure(
      IOSOptions(AppStrings.appName,
          imageName: 'app_logo',
          supportsVideo: true,
          maximumCallGroups: 1,
          maximumCallsPerCallGroup: 1),
      didReceiveStartCallAction: _didReceiveStartCallAction,
      performAnswerCallAction: _performAnswerCallAction,
      performEndCallAction: _performEndCallAction,
      didActivateAudioSession: _didActivateAudioSession,
      didDisplayIncomingCall: _didDisplayIncomingCall,
      didPerformSetMutedCallAction: _didPerformSetMutedCallAction,
      didPerformDTMFAction: _didPerformDTMFAction,
      didToggleHoldAction: _didToggleHoldAction,
    );

    _configureVoIP();
  }

  // Configures a voip push notification
  Future<void> _configureVoIP() async {
    await _voipPush.requestNotificationPermissions();
    _voipPush.onTokenRefresh.listen(onToken);
  }

  /// Called when the device token changes
  void onToken(String token) {
    // send token to your apn provider server
    SharedPreferenceManager().setVoIPToken(token);
  }

  //callKit CallBacks
  /// Use startCall to ask the system to start a call - Initiate an outgoing call from this point
  Future<void> startCall(String handle, String localizedCallerName) async {
    /// Your normal start call action
    await AppData.callKit.startCall(currentCallId, handle, localizedCallerName);
  }

  Future<void> reportEndCallWithUUID(String uuid, EndReason reason) async {
    await AppData.callKit.reportEndCallWithUUID(uuid, reason);
  }

  /// Event Listener Callbacks

  Future<void> _didReceiveStartCallAction(String uuid, String handle) async {
  }

  Future<void> _performAnswerCallAction(String uuid) async {
    // Called when the user answers an incoming call
  }

  Future<void> _performEndCallAction(String uuid) async {
    await AppData.callKit.endCall(this.currentCallId);
    AppData.callKitCurrentCallId = null;
  }

  Future<void> _didActivateAudioSession() async {
    // you might want to do following things when receiving this event:
    // - Start playing ringback if it is an outgoing call
  }

  Future<void> _didDisplayIncomingCall(String error, String uuid, String handle,
      String localizedCallerName, bool fromPushKit) async {
    // You will get this event after RNCallKeep finishes showing incoming call UI
    // You can check if there was an error while displaying
    AppData.callKitCurrentCallId = uuid;
  }

  Future<void> _didPerformSetMutedCallAction(bool mute, String uuid) async {
    // Called when the system or user mutes a call
  }

  Future<void> _didPerformDTMFAction(String digit, String uuid) async {
    // Called when the system or user performs a DTMF action
  }

  Future<void> _didToggleHoldAction(bool hold, String uuid) async {
    // Called when the system or user holds a call
  }

  String get currentCallId {
    if (AppData.callKitCurrentCallId == null) {
      final uuid = new Uuid();
      AppData.callKitCurrentCallId = uuid.v4();
    }

    return AppData.callKitCurrentCallId;
  }

  Future<void> _localNotificationSetup() async {
    final NotificationAppLaunchDetails notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    initialRoute = "/LauncherScreen";
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails.payload;

      initialRoute = "/IncomingCallScreen";
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    const MacOSInitializationSettings initializationSettingsMacOS =
    MacOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {}
          selectedNotificationPayload = payload;

          selectNotificationSubject.add(payload);
        });

    flutterLocalNotificationsPlugin.cancelAll();
  }

  void _configureSelectNotificationSubject() {

    selectNotificationSubject.stream.listen((String payload) async {
      Map<String, dynamic> mapPayloadData =  json.decode(payload) as Map<String, dynamic>;
      _handleNavigation(mapPayloadData);
    });
  }

  _handleNavigation(Map<String, dynamic> data){

    if (!data.containsKey(ConCubeConstants.CC_NOTIFICATION_TYPE)){
      if(int.parse(data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_LESSON_DETAIL){
        int lessonId = int.parse(data[AppConstants.LESSON_ID]);
        int cookId = int.parse(data[AppConstants.COOK_ID]);
        int lessonBookingId = int.parse(data[AppConstants.BOOKING_ID]);
        bool isFromCook = (AppData.user.role == AppConstants.ROLE_COOK);

        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        Navigator.of(AppData.appContext).push(MaterialPageRoute(
            builder: (context) => LessonDetailsScreen(cookId: cookId, id: lessonId, isFromCook: isFromCook, lessonBookingId: lessonBookingId,)));

      }else if(int.parse(data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_BOOKINGS_REQ_LIST){
        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        Navigator.of(AppData.appContext).push(MaterialPageRoute(
            builder: (context) => MyRequestScreen()));
      } else if(int.parse(data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_BOOKINGS_LIST){
        Navigator.of(AppData.appContext).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen(selectedTabIndex: AppConstants.DASHBOARD_BOOKINGS,)),
            ModalRoute.withName(""));
      }else if(int.parse(data[AppConstants.REDIRECT] ?? "-1") == AppConstants.REDIRECT_TO_REVIEWS_LIST){
        Navigator.of(AppData.appContext).popUntil((route) => route.isFirst);
        Navigator.of(AppData.appContext).push(MaterialPageRoute(
            builder: (context) => UserReviewsScreens(AppData.user.id, AppData.user.firstName, isCook: (AppData.user.role == AppConstants.ROLE_COOK),)));
      }else{
        Navigator.of(AppData.appContext).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen(selectedTabIndex: AppConstants.DASHBOARD_BOOKINGS,)),
            ModalRoute.withName(""));
      }
    }
  }

}

import 'dart:convert';
import 'dart:io';


import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/constants/ConCubeConstants.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/launcher/LauncherScreen.dart';
import 'package:cooking_app/modules/video_chat/CallScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../main.dart';

class IncomingCallScreen extends StatefulWidget {
  P2PSession callSession;
  String selectedNotificationPayload;

  IncomingCallScreen(this.callSession, {this.selectedNotificationPayload});

  @override
  _IncomingCallScreenState createState() => _IncomingCallScreenState();
}

const String _TAG = "IncomingCallScreen";

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  ValueNotifier<CubeUser> caller = ValueNotifier(CubeUser());

  bool isFromKilledState = false;
  bool isSessionCreated = false;
  Map<String, dynamic> callInfo;
  bool isCallEnded = false;

  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();

  int cookId;
  int lessonId;
  int lessonBookingId;
  int userId;
  int hasCookReviewedTheUser;
  int hasUserReviewedTheCook;

  @override
  void initState() {
    flutterLocalNotificationsPlugin.cancelAll();
    if (Platform.isIOS) {
      audioCache.fixedPlayer?.notificationService?.startHeadlessService();
      audioPlayer.notificationService.startHeadlessService();
    }
    if (widget.callSession == null) {
      isFromKilledState = true;

      callInfo = jsonDecode(widget.selectedNotificationPayload);
      caller.value.fullName = callInfo[ConCubeConstants.CC_CALLER_USER_NAME];
      caller.value.id = int.parse(callInfo[ConCubeConstants.CC_CALLER_USER_ID]);
      SharedPreferenceManager().getUser().then((value){
        AppData.user = value;

          cookId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.COOK_ID] ?? "-1");
          lessonId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.LESSON_ID] ?? "-1");
          lessonBookingId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.LESSON_BOOKING_ID] ?? "-1");
           userId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.USER_ID] ?? "-1");
           hasCookReviewedTheUser = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.HAS_COOK_REVIEWED_THE_USER] ?? "-1");
           hasUserReviewedTheCook = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.HAS_USER_REVIEWED_THE_COOK] ?? "-1");

      });
      _initCustomMediaConfigs();
      _initCalls();
    } else if (widget.callSession?.cubeSdp?.userInfo != null) {
      isSessionCreated = true;
      caller.value.fullName = widget
          .callSession.cubeSdp.userInfo[ConCubeConstants.CC_CALLER_USER_NAME];
      caller.value.id = int.parse(widget.callSession.cubeSdp
              .userInfo[ConCubeConstants.CC_CALLER_USER_ID] ??
          "-1");

        cookId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.COOK_ID] ?? "-1");
        lessonId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.LESSON_ID] ?? "-1");
        lessonBookingId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.LESSON_BOOKING_ID] ?? "-1");
        userId = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.USER_ID] ?? "-1");
      hasCookReviewedTheUser = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.HAS_COOK_REVIEWED_THE_USER] ?? "-1");
      hasUserReviewedTheCook = int.parse(widget.callSession.cubeSdp.userInfo[ConCubeConstants.HAS_USER_REVIEWED_THE_COOK] ?? "-1");

    }
    super.initState();
    audioCache.loop('audio/sample_ringtone.mp3').then((value) {
      audioPlayer = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.callSession?.onSessionClosed = (callSession) {
      if (isFromKilledState) {
        audioPlayer?.stop();
        audioCache?.clearAll();
        print("IncomingCallScreen :: Call Ended build going to LauncherScreen");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LauncherScreen()));
      } else {
        audioPlayer?.stop();
        audioCache?.clearAll();
        print("IncomingCallScreen :: Call Ended build pop");
        Navigator.pop(context);
      }
    };

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15, right: 15),
              child: Text(_getCallTitle(), style: TextStyle(fontSize: 28)),
            ),
            ValueListenableProvider<CubeUser>.value(
                value: caller,
                child: Consumer<CubeUser>(builder: (context, value, child) {
                  return Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 30),
                    child: Text("${value?.fullName ?? ""}",
                        style: TextStyle(fontSize: 20)),
                  );
                }),
              ),
              Offstage(
                  offstage: (isSessionCreated || isCallEnded),
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 8),
                    child: Text("Setting up your call session",
                        style: TextStyle(fontSize: 12)),
                  )),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 36),
                    child: FloatingActionButton(
                      heroTag: "RejectCall",
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                    ),
                    backgroundColor: isSessionCreated ? Colors.red : Colors
                        .grey,
                    onPressed: () =>
                    (isSessionCreated) ? _rejectCall(
                        context, widget.callSession) : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 36),
                  child: FloatingActionButton(
                    heroTag: "AcceptCall",
                    child: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                      backgroundColor:
                          isSessionCreated ? Colors.green : Colors.grey,
                      onPressed: () => (isSessionCreated)
                          ? _acceptCall(context, widget.callSession)
                          : null,
                    ),
                  ),
                ],
              ),
              Offstage(
                  offstage: !isCallEnded,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 8),
                    child: Text("Call Ended",
                        style: TextStyle(fontSize: 16, color: AppColors.black)),
                  )),
            ],
        ),
      ),
      ),
    );
  }

  _getCallTitle() {
    String callType;

    if (callInfo != null) {
      return "Incoming ${callInfo[ConCubeConstants.CC_CALL_TYPE_STRING]}";
    }

    switch (widget.callSession?.callType ?? -1) {
      case CallType.VIDEO_CALL:
        callType = "Video";
        break;
      case CallType.AUDIO_CALL:
        callType = "Audio";
        break;

      default:
        callType = "-";
        break;
    }

    return "Incoming $callType call";
  }

  void _acceptCall(BuildContext context, P2PSession callSession) {
    audioPlayer?.stop();
    audioCache?.clearAll();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(callSession, true,
            caller: caller.value, isFromKilledState: isFromKilledState, cookId: cookId, lessonId: lessonId, userId: userId,  lessonBookingId: lessonBookingId, hasCookReviewedTheUser: hasCookReviewedTheUser, hasUserReviewedTheCook: hasUserReviewedTheCook,),
      ),
    );
  }

  void _rejectCall(BuildContext context, P2PSession callSession) {
    audioPlayer?.stop();
    audioCache?.clearAll();
    callSession.reject();
  }

  Future<bool> _onBackPressed(BuildContext context) {
    return Future.value(false);
  }

  void _initCustomMediaConfigs() {
    RTCMediaConfig mediaConfig = RTCMediaConfig.instance;
    mediaConfig.minHeight = 720;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;
  }

  Future<void> _initCalls() async {
    var user = await SharedPreferenceManager().getUser();
    LogManager().log(
        _TAG, "_initCalls", "Calling ConCubeUtils.createSessionAndLogin");
    if (user.ccId != null) {
      AppData.cubeUser =
          ConCubeUtils.getCubeUserObject(user, ccId: user.ccId);
      await ConCubeUtils.createSessionAndLogin(AppData.cubeUser,
          forceCreateSession: true);
    }

    LogManager().log(_TAG, "_initCalls", "Completed createSessionAndLogin");

    AppData.callClient.onReceiveNewSession = (callSession) {
      if (AppData.currentCall != null &&
          AppData.currentCall.sessionId != callSession.sessionId) {
        callSession.reject();

        return;
      }
      widget.callSession = callSession;

      isSessionCreated = true;
      setState(() {});
    };

    AppData.callClient.onSessionClosed = (callSession) {
      if (AppData.currentCall != null &&
          AppData.currentCall.sessionId == callSession.sessionId) {
        AppData.currentCall = null;
      }
      if (isFromKilledState) {
        audioPlayer?.stop();
        audioCache?.clearAll();
        print("IncomingCallScreen :: Call Ended _initCalls going to LauncherScreen");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LauncherScreen()));
      }
    };

    Future.delayed(Duration(seconds: 25)).then((value) async {
      if (!isSessionCreated) {
        audioPlayer?.stop();
        audioCache?.clearAll();
        setState(() {
          isCallEnded = true;
        });

        await Future.delayed(Duration(seconds: 2));

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LauncherScreen()));
      }
    });
  }
}

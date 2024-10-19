import 'dart:async';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/constants/ConCubeConstants.dart';
import 'package:cooking_app/modules/launcher/LauncherScreen.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/video_chat/LessonDetailsBottomSheet.dart';
import 'package:cooking_app/modules/video_chat/ReviewBottomSheet.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class CallScreen extends StatefulWidget {
  final P2PSession callSession;
  final bool isIncoming;
  final CubeUser caller;
  final String calleeName;
  final int calleeId;
  final bool isFromKilledState;
  final cookId;
  final lessonId;
  final lessonBookingId;
  final userId;
  final int hasCookReviewedTheUser;
  final int hasUserReviewedTheCook;

  CallScreen(this.callSession, this.isIncoming,
      {this.caller,
      this.calleeName,
      this.calleeId,
      this.isFromKilledState = false, this.cookId, this.lessonId, this.lessonBookingId, this.userId, this.hasCookReviewedTheUser, this.hasUserReviewedTheCook});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> implements RTCSessionStateCallback<P2PSession> {
  static const String TAG = "_VideoCallScreenState";

  ValueNotifier<bool> isCallPicked = ValueNotifier(false);
  bool _isCameraEnabled = true;
  bool _isSpeakerEnabled = true;
  bool _isMicMute = false;
  ValueNotifier<CubeUser> otherUser = ValueNotifier(CubeUser());
  Map<int, RTCVideoRenderer> streams = {};
  Timer _timerForCall;
  ValueNotifier<String> timeString = ValueNotifier("");
  int timeInSeconds = 0;
  int cookId;
  int lessonId;
  int lessonBookingId;
  int userId;
  LessonDetailsModel lessonDetails;
  int hasCookReviewedTheUser;
  int hasUserReviewedTheCook;

  @override
  void initState() {
    cookId = widget.cookId;
    lessonId = widget.lessonId;
    lessonBookingId = widget.lessonBookingId;
    userId = widget.userId;
    hasCookReviewedTheUser = widget.hasCookReviewedTheUser;
    hasUserReviewedTheCook = widget.hasUserReviewedTheCook;

    super.initState();

    if (widget.isFromKilledState) {
      AppData.callClient.onSessionClosed = (callSession) {
        if (AppData.currentCall != null &&
            AppData.currentCall.sessionId == callSession.sessionId) {
          AppData.currentCall = null;
        }
        if (widget.isFromKilledState) {

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LauncherScreen()));
        }
      };
    }

    widget.callSession.onLocalStreamReceived = _addLocalMediaStream;
    widget.callSession.onRemoteStreamReceived = _addRemoteMediaStream;
    widget.callSession.onSessionClosed = _onSessionClosed;

    widget.callSession.setSessionCallbacksListener(this);
    if (widget.isIncoming) {
      widget.callSession.acceptCall(<String, String>{
        ConCubeConstants.CC_RECEIVER_USER_ID:
            "${CubeChatConnection.instance.currentUser.id}",
        ConCubeConstants.CC_RECEIVER_USER_NAME:
        "${CubeChatConnection.instance.currentUser.fullName}"
      });
      //if (widget.callSession.callType == CallType.AUDIO_CALL && _timerForCall == null) {
        _initiateCallDuration();
      //}
    } else {
      Map<String, String> callData = <String, String>{
        ConCubeConstants.CC_CALLER_USER_ID: "${CubeChatConnection.instance
            .currentUser.id}",
        ConCubeConstants.CC_CALLER_USER_NAME: "${CubeChatConnection.instance
            .currentUser.fullName ?? ""}"
      };

      callData.putIfAbsent(ConCubeConstants.COOK_ID, () => "$cookId");
      callData.putIfAbsent(ConCubeConstants.LESSON_ID, () => "$lessonId");
      callData.putIfAbsent(ConCubeConstants.LESSON_BOOKING_ID, () => "$lessonBookingId");
      callData.putIfAbsent(ConCubeConstants.USER_ID, () => "$userId");
      callData.putIfAbsent(ConCubeConstants.HAS_COOK_REVIEWED_THE_USER, () => "$hasCookReviewedTheUser");
      callData.putIfAbsent(ConCubeConstants.HAS_USER_REVIEWED_THE_COOK, () => "$hasUserReviewedTheCook");


      widget.callSession.startCall(callData).then((value) {

        LogManager().log(TAG, "startCall", "After startCall");

        ///Send CC Call Push notification
        CreateEventParams params = CreateEventParams();
        params.parameters = {
          ConCubeConstants.CC_CALL_MESSAGE:
          "${CubeChatConnection.instance.currentUser.fullName}"+AppStrings.userIsCalling,
          /// 'message' field is required
          ConCubeConstants.CC_CALLER_USER_ID:
              "${CubeChatConnection.instance.currentUser.id}",
          ConCubeConstants.CC_CALLER_USER_NAME:
              "${CubeChatConnection.instance.currentUser.fullName}",
          ConCubeConstants.CC_CALL_TYPE: "${widget.callSession.callType}",
          ConCubeConstants.CC_CALL_TYPE_STRING:
              "${(widget.callSession.callType == CallType.VIDEO_CALL) ? AppStrings.videoCallLabel : AppStrings.audioCallLabel}",
          ConCubeConstants.CC_NOTIFICATION_TYPE:
              ConCubeConstants.CC_NOTIFICATION_TYPE,
          ConCubeConstants.CLICK_ACTION:
              ConCubeConstants.FLUTTER_NOTIFICATION_CLICK,
        };

        /// to send VoIP push notification to iOS
          params.parameters.putIfAbsent(ConCubeConstants.CC_IOS_VOIP, () => 1);

        params.notificationType = NotificationType.PUSH;
        params.environment = AppData.isProduction
            ? CubeEnvironment.PRODUCTION
            : CubeEnvironment.DEVELOPMENT;
        params.usersIds = [widget.calleeId];

        createEvent(params.getEventForRequest()).then((cubeEvent) {
          LogManager().log(TAG, "createEvent",
              "After calling createEvent for sending push notification");
        }).catchError((error) {
          LogManager().log(TAG, "createEvent",
              "Error while sending push notification after startCall in createEvent",
              e: error);
        });

      }).catchError((error) {
        LogManager().log(
            TAG, "startCall", "Error while calling callSession.startCall",
            e: error);
      });
    }

    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
    if (_timerForCall != null) {
      _timerForCall.cancel();
    }
    streams.forEach((opponentId, stream) async {
      await stream.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            body: _isVideoCall()
                ? OrientationBuilder(
              builder: (context, orientation) {
                return Center(
                  child: Container(
                    child: orientation == Orientation.portrait
                        ? Column(
                        mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: renderStreamsGrid(orientation))
                          : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: renderStreamsGrid(orientation)),
                    ),
                  );
                },
              )
                  : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        AppStrings.audioCallLabel,
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Text(
                          "${((widget.isIncoming)
                              ? widget.caller?.fullName
                              : widget.calleeName) ?? ""}",
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle1),
                    ),
                    ValueListenableProvider<bool>.value(
                      value: isCallPicked,
                      child: Consumer<bool>(
                          builder: (context, value, child) {
                            return (widget.isIncoming) ? Container() : ((value)
                                ? Container()
                                : Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text("${(value) ? "" : AppStrings.calling}",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .subtitle1),
                            ));
                          }),
                    ),

                    ValueListenableProvider<String>.value(value: timeString,
                      child: Consumer<String>(builder: (context, value, child) {
                        return Offstage(offstage: value.isEmpty, child: Padding(
                          padding: const EdgeInsets.only(
                              top: AppDimensions.generalTopPadding),
                          child: Text("${value ?? ""}", style: Theme
                              .of(context)
                              .textTheme
                              .subtitle2),
                        ),);
                      },),),

                  ],
                ),
            ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _getActionsPanel(),
        ),

        Align(
            alignment: Alignment.bottomRight, child: Padding(
              padding: const EdgeInsets.only(bottom: 100, right: 10),
                  child: GestureDetector(onTap: (){
                      LessonDetailsBottomSheet.lessonDetailsSheet(context, lessonId, (lessonDetailsModel){
                        lessonDetails = lessonDetailsModel;
                      }, lessonDetailsModel: lessonDetails);
                  },
                    child: Container(decoration: BoxDecoration(color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(AppStrings.viewLessonDetails, textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.subtitle1.apply(color: AppColors.white),),
                      )
                ,),
                  ),)),

      ],
    );
  }

  @override
  void onConnectedToUser(P2PSession session, int userId) {

  }

  @override
  void onConnectionClosedForUser(P2PSession session, int userId) {
    _removeMediaStream(session, userId);
  }

  @override
  void onDisconnectedFromUser(P2PSession session, int userId) {
  }

  void _addLocalMediaStream(MediaStream stream) {
    _onStreamAdd(CubeChatConnection.instance.currentUser.id, stream);
  }

  void _addRemoteMediaStream(session, int userId, MediaStream stream) {
    isCallPicked.value = true;
    //if (widget.callSession.callType == CallType.AUDIO_CALL && _timerForCall == null) {
      _initiateCallDuration();
    //}
    if (widget.caller == null) {
      getUserById(userId).then((value) {
        otherUser.value = value;
      });
    }
    _onStreamAdd(userId, stream);
  }

  void _removeMediaStream(callSession, int userId) {
    RTCVideoRenderer videoRenderer = streams[userId];
    if (videoRenderer == null) return;

    videoRenderer.srcObject = null;
    videoRenderer.dispose();

    setState(() {
      streams.remove(userId);
    });
  }

  void _onSessionClosed(session) {
    widget.callSession.removeSessionCallbacksListener();

    if (_timerForCall != null) {
      _timerForCall.cancel();
    }

    if (widget.isFromKilledState) {
      if (AppData?.callKitCurrentCallId?.isEmpty == false) {
        AppData.callKit?.endCall(AppData?.callKitCurrentCallId);
      }

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LauncherScreen()));

    } else {
      if (AppData?.callKitCurrentCallId?.isEmpty == false) {
        AppData.callKit?.endCall(AppData?.callKitCurrentCallId);
      }

      Navigator.pop(context);

      if(timeInSeconds > 0){
        if(AppData.user.role == AppConstants.ROLE_COOK){
        if(hasCookReviewedTheUser == 0){
          ReviewBottomSheet.reviewSheet(context, cookId, lessonId, lessonBookingId, userId, isOpenedFromCookSide: (AppData.user.role == AppConstants.ROLE_COOK));
        }
        }else if(hasUserReviewedTheCook == 0){
          ReviewBottomSheet.reviewSheet(context, cookId, lessonId, lessonBookingId, userId, isOpenedFromCookSide: (AppData.user.role == AppConstants.ROLE_COOK));
        }

      }

    }
  }

  void _onStreamAdd(int opponentId, MediaStream stream) async {
    RTCVideoRenderer streamRender = RTCVideoRenderer();
    await streamRender.initialize();
    streamRender.srcObject = stream;
    setState(() => streams[opponentId] = streamRender);
  }

  List<Widget> renderStreamsGrid(Orientation orientation) {

    List<Widget> streamsExpanded = streams.entries.map((entry) {
      return Expanded(
          child: ClipRRect(
            child: Stack(
              children: [
                RTCVideoView(
                  entry.value,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
                (CubeChatConnection.instance.currentUser.id == entry.key)
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Container(
                              color: AppColors.lightGray,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "${CubeChatConnection?.instance?.currentUser?.fullName ?? ""}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .apply(color: AppColors.white)),
                              )),
                        ))
                    : Align(
                        alignment: Alignment.topCenter,
                        child: (widget.caller != null)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: Container(
                                  color: AppColors.lightGray,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "${widget.caller?.fullName ?? ""}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .apply(color: AppColors.white)),
                                  ),
                                ),
                              )
                            : ValueListenableProvider<CubeUser>.value(
                                value: otherUser,
                                child: Consumer<CubeUser>(
                                  builder: (context, value, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 40.0),
                                      child: Container(
                                        color: AppColors.lightGray,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              "${widget.calleeName ?? ""}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .apply(
                                                      color: AppColors.white)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
              ],
            ),
          ),
        );
      },
    ).toList();

    if (streamsExpanded.length > 1) {
      var userIdsList = streams.keys.toList();
      if (userIdsList[0] == CubeChatConnection.instance.currentUser.id) {
        var currentUserStreamWidget = streamsExpanded[0];
        streamsExpanded[0] = streamsExpanded[1];
        streamsExpanded[1] = currentUserStreamWidget;
      }
    }

    return streamsExpanded;
  }

  Widget _getActionsPanel() {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32)),
        child: Container(
          padding: EdgeInsets.all(4),
          color: AppColors.callActionsBackgroundColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: AppStrings.heroTagMute,
                  child: Icon(
                    _isMicMute ? Icons.mic_off : Icons.mic,
                    color: _isMicMute ? AppColors.grayColor : AppColors.white,
                  ),
                  onPressed: () => _muteMic(),
                  backgroundColor: AppColors.callButtonsBackgroundColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: FloatingActionButton(
                  elevation: 0,
                  heroTag: AppStrings.heroTagSpeaker,
                  child: Icon(
                    _isSpeakerEnabled ? Icons.volume_up : Icons.volume_off,
                    color: _isSpeakerEnabled ? AppColors.white : AppColors.grayColor,
                  ),
                  onPressed: () => _switchSpeaker(),
                  backgroundColor: AppColors.callButtonsBackgroundColor,
                ),
              ),
              Offstage(offstage: !_isVideoCall(),
                child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: FloatingActionButton(
                    elevation: 0,
                    heroTag: AppStrings.heroTagSwitchCamera,
                    child: Icon(
                      Icons.switch_video,
                      color: _isVideoEnabled() ? AppColors.white : AppColors.grayColor,
                    ),
                    onPressed: () => _switchCamera(),
                    backgroundColor: AppColors.callButtonsBackgroundColor,
                  ),
                ),
              ),
              Offstage(offstage: !_isVideoCall(),
                child: Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: FloatingActionButton(
                    elevation: 0,
                    heroTag: AppStrings.heroTagToggleCamera,
                    child: Icon(
                      _isVideoEnabled() ? Icons.videocam : Icons.videocam_off,
                      color: _isVideoEnabled() ? AppColors.white : AppColors.grayColor,
                    ),
                    onPressed: () => _toggleCamera(),
                    backgroundColor: AppColors.callButtonsBackgroundColor,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(),
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: FloatingActionButton(
                  child: Icon(
                    Icons.call_end,
                    color: AppColors.white,
                  ),
                  backgroundColor: AppColors.callCancelRed,
                  onPressed: () => _endCall(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _endCall() {
    if (_timerForCall != null) {
      _timerForCall.cancel();
    }
    if (AppData?.callKitCurrentCallId?.isEmpty == false) {
      AppData.callKit?.endCall(AppData?.callKitCurrentCallId);
    }
    widget.callSession.hungUp();
  }

  _muteMic() {
    setState(() {
      _isMicMute = !_isMicMute;
      widget.callSession.setMicrophoneMute(_isMicMute);
    });
  }

  _switchCamera() {
    if (!_isVideoEnabled()) return;

    widget.callSession.switchCamera();
  }

  _toggleCamera() {
    if (!_isVideoCall()) return;

    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
      widget.callSession.setVideoEnabled(_isCameraEnabled);
    });
  }

  bool _isVideoEnabled() {
    return _isVideoCall() && _isCameraEnabled;
  }

  bool _isVideoCall() {
    return CallType.VIDEO_CALL == widget.callSession.callType;
  }

  _switchSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
      widget.callSession.enableSpeakerphone(_isSpeakerEnabled);
    });
  }

  void _initiateCallDuration() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _timerForCall = timer;

      var hours = (timer.tick / 3600).truncate();
      var minutes = ((timer.tick - (hours * 3600)) / 60).truncate();
      var seconds = timer.tick - (hours * 3600) - (minutes * 60);

      timeInSeconds = timer.tick;

      timeString.value = hours.toString().padLeft(2, '0') +
          ' : ' +
          minutes.toString().padLeft(2, '0') +
          ' : ' +
          seconds.toString().padLeft(2, '0');
    });
  }
}

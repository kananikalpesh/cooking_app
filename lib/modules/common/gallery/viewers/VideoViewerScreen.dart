import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:provider/provider.dart';

import 'package:video_player/video_player.dart';

class VideoViewerScreen extends StatefulWidget {
  final String url;
  final bool fromGallery;
  final bool isLocalFile;

  VideoViewerScreen(this.url,
      {this.fromGallery = false, this.isLocalFile = false});

  @override
  _VideoViewerScreenState createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  ValueNotifier<bool> _loading = ValueNotifier(true);
  VideoPlayerController _videoController;

  ValueNotifier<Duration> _videoDuration = ValueNotifier(Duration(
      days: 0,
      hours: 0,
      microseconds: 0,
      milliseconds: 0,
      minutes: 0,
      seconds: 0));

  ValueNotifier<Duration> _currentVideoPos = ValueNotifier(Duration(
      days: 0,
      hours: 0,
      microseconds: 0,
      milliseconds: 0,
      minutes: 0,
      seconds: 0));

  ValueNotifier<IconData> _videoControllerIcon =
      ValueNotifier(Icons.play_circle_outline);

  @override
  void initState() {
    _videoController = ((widget.isLocalFile)
        ? VideoPlayerController.file(
            File(widget.url),
          )
        : VideoPlayerController.network(widget.url))
      ..setVolume(1.0)
      ..initialize().then((value) {
        _loading.value = !_videoController.value.isInitialized;
      });

    _videoController.addListener(() {
      if (this.mounted) {
        _videoDuration.value = _videoController.value.duration;
        _currentVideoPos.value = _videoController.value.position;

        if (_currentVideoPos.value != null && _videoDuration.value != null) {
          if ((_currentVideoPos.value.compareTo(_videoDuration.value) ?? -1) ==
              0) {
            if (!_videoController.value.isPlaying) {
              _videoControllerIcon.value = Icons.play_circle_outline;
            }
          }
        }
      }
    });

    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    playOrPauseVideo();
    _videoController.dispose();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleGallery);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height - 32,
        child: Stack(
          children: [
            ValueListenableProvider<bool>.value(
              value: _loading,
              child: Consumer<bool>(
                builder: (context, value, child) {
                  return (value)
                      ? Center(
                    child: SizedBox(
                      height: 38,
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : Center(
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: AppColors.lightBlue.withOpacity(0.5),
                child: Padding(
                  padding:
                  const EdgeInsets.all(AppDimensions.generalTopPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: IconButton(
                          onPressed: () {
                            if (!_loading.value) {
                              playOrPauseVideo();
                            }
                          },
                          icon: ValueListenableProvider<IconData>.value(
                            value: _videoControllerIcon,
                            child: Consumer<IconData>(
                              builder: (context, value, child) {
                                return Icon(value,
                                    color: AppColors.white, size: 38.0);
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ValueListenableProvider<Duration>.value(
                          value: _currentVideoPos,
                          child: Consumer<Duration>(
                            builder: (context, value, child) {
                              return Text(
                                "${_getDuration(value)}",
                                style: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.black),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(height: 30, child: videoSlider()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: ValueListenableProvider<Duration>.value(
                          value: _videoDuration,
                          child: Consumer<Duration>(
                            builder: (context, value, child) {
                              return Text(
                                "${_getDuration(value)}",
                                style: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.black),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 32,
              left: 10,
              child: Offstage(
                offstage: widget.fromGallery,
                child: Container(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    iconSize: 30,
                    icon: Center(
                        child: Icon(
                          (Platform.isIOS) ? Icons.arrow_back_ios : Icons
                              .arrow_back,
                          color: AppColors.white,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoSlider() {
    return ValueListenableProvider<Duration>.value(
      value: _currentVideoPos,
      child: Consumer<Duration>(
        builder: (context, value, child) {
          return Slider(
            value: (value ?? Duration(seconds: 00)).inSeconds.toDouble(),
            onChanged: (double newValue) {
              if (_videoDuration.value.inSeconds != value.inSeconds) {
                var draggedToValue = newValue / _videoDuration.value.inSeconds;
                Duration position =
                    _videoController.value.duration * draggedToValue;
                _videoController.seekTo(position);
              }
            },
            min: 00.00,
            max: (_videoDuration.value ?? Duration(seconds: 10))
                .inSeconds
                .toDouble(),
            activeColor: AppColors.white,
            inactiveColor: AppColors.backgroundGrey300,
          );
        },
      ),
    );
  }

  String _getDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes =
        (duration == null) ? "00" : twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds =
        (duration == null) ? "00" : twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  playOrPauseVideo() {
    if (_videoController != null) {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _videoControllerIcon.value = Icons.play_circle_outline;
      } else {
        if (_videoController.value != null) {
          if (_videoController.value.duration
                  .compareTo(_videoController.value.position) ==
              0) {
            _videoController.seekTo(Duration(
                days: 0,
                hours: 0,
                minutes: 0,
                seconds: 0,
                milliseconds: 0,
                microseconds: 0));
          }

          _videoControllerIcon.value = Icons.pause_circle_outline;
          _videoController.play();
        }
      }
    }
  }
}

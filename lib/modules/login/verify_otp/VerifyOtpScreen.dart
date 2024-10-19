import 'dart:convert';
import 'dart:ui';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/login/set_password/SetPasswordScreen.dart';
import 'package:cooking_app/modules/login/verify_otp/VerifyOtpBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart' as crypto;

class VerifyOtpScreen extends StatefulWidget {
  final String _emailId;

  VerifyOtpScreen(this._emailId);

  @override
  State<StatefulWidget> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  FocusNode _focusOtp;

  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormFieldState>();

  VerifyOtpBloc _bloc;
  String _otp = "";
  ValueNotifier<String> checkOtpMessage =
      ValueNotifier(AppStrings.otpSentOnMobileAndEmail);

  ValueNotifier<String> _apiResponseError = ValueNotifier("");

  CountdownTimerController _controller;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 600;

  ValueNotifier<bool> _isResendOtpVisible = ValueNotifier(false);

  @override
  void initState() {
    _bloc = VerifyOtpBloc();

    _controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);

    _bloc.obsVerifyOtp.stream.listen((result) async {
      if (result.error != null) {
        _bloc.isLoading.value = false;
        _apiResponseError.value = result.error;
      } else {
        _proceed();
      }
    });

    _bloc.obsResendOtp.stream.listen((result) {
      if (result.error == null){
        checkOtpMessage.value = AppStrings.newOtpSentOnMobileAndEmail;
        _isResendOtpVisible.value = false;
        _controller = CountdownTimerController(endTime: (DateTime
            .now()
            .millisecondsSinceEpoch + 1000 * 600),
            onEnd: onEnd);
      }else{

      }
    });

    _focusOtp = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusOtp.dispose();
    _bloc.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/login_background.jpg"), fit: BoxFit.fill
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,

            child: BaseFormBodyUnsafe(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppDimensions.generalPadding,
                      AppDimensions.loginScreensTopBottomMargin,
                      AppDimensions.generalPadding,
                      AppDimensions.loginScreensTopBottomMargin),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(alignment: Alignment.center,
                        child: Text(AppStrings.verifyOtpLabel, style: Theme
                            .of(context)
                            .textTheme
                            .headline4,),),
                      SizedBox(height: AppDimensions.maxPadding),
                      Image.asset(
                        "assets/app_logo.png", height: AppDimensions
                          .loginScreensLogoSize,),
                      Expanded(child: Container(),),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: TextFormField(
                          key: _otpKey,
                          decoration: InputDecoration(
                              labelText: AppStrings.otpButtonLabel),
                          maxLines: 1,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          autofocus: false,
                          focusNode: _focusOtp,
                          onSaved: (value) => _otp = value,
                          validator: ValidationUtils.getEmptyValidator(
                              context, AppStrings.emptyOtp),
                        ),
                      ),
                      ValueListenableProvider<String>.value(
                        value: _apiResponseError,
                        child: Consumer<String>(
                          builder: (context, value, child) {
                            return Offstage(
                              offstage: ((value?.isEmpty ?? true)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: AppDimensions.generalPadding,
                                  right: AppDimensions.generalPadding,
                                  top: AppDimensions.generalPadding,
                                ),
                                child: Text(
                                  "$value",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.errorTextColor),
                                ),
                              ));
                          },
                        ),
                      ),

                      SizedBox(
                        height: AppDimensions.maxPadding,
                      ),
                      ValueListenableProvider<bool>.value(
                        value: _bloc.isLoading,
                        child: Consumer<bool>(
                          builder: (context, loading, child) {
                            return (loading)
                                ? _getLoaderWidget()
                                : _getButton();
                          },
                        ),
                      ),
                      SizedBox(
                        height: AppDimensions.maxPadding,
                      ),
                      ValueListenableProvider<String>.value(
                        value: checkOtpMessage,
                        child: Consumer<String>(
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: AppDimensions.generalPadding,
                                right: AppDimensions.generalPadding,
                                bottom: AppDimensions.generalPadding,
                              ),
                              child: Text("$value",
                                  style:
                                  Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: AppDimensions.generalPadding,
                      ),
                      ValueListenableProvider<bool>.value(
                        value: _isResendOtpVisible,
                        child: Consumer<bool>(
                          builder: (context, isVisible, child) {
                            return (isVisible) ? GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppStrings.resendOtpDesc, style: Theme
                                      .of(context)
                                      .textTheme
                                      .subtitle2,),
                                  SizedBox(width: 10,),
                                  ValueListenableProvider<bool>.value(
                                    value: _bloc.isResendOtpLoading,
                                    child: Consumer<bool>(
                                      builder: (context, loading, child) {
                                        return (loading)
                                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                                            : Text(AppStrings.resendOtpLabel,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .subtitle1
                                              .apply(
                                            decoration: TextDecoration
                                                .underline,
                                          ),);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                var _userData = <String, dynamic>{
                                  'lfv': widget._emailId,
                                };

                                _bloc.event.add(EventModel(
                                    VerifyOtpBloc.RESEND_OTP_EVENT,
                                    data: _userData));
                              },
                            ) : Column(
                              children: [
                                Text(
                                  AppStrings.resendOtpTimerMsg, style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle2,),
                                SizedBox(height: 5,),
                                CountdownTimer(
                                  controller: _controller, onEnd: onEnd,
                                  endTime: endTime, textStyle: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle1,),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onEnd() {
    _isResendOtpVisible.value = true;
  }

  Widget _getButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _processForm();
            },
            child: Text(AppStrings.verifyLabel),
          ),
        ),
      ],
    );
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  _processForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _apiResponseError.value = "";

      var _content = new Utf8Encoder().convert(_otp);
      var _digest = crypto.sha512.convert(_content);
      var _sha512Pass = _digest;

      var _userData = <String, dynamic>{
        'lfv': widget._emailId,
        //'k': _otp,
        'k': _otp,
      };

      _bloc.isLoading.value = true;
      _bloc.event.add(
          EventModel(VerifyOtpBloc.VERIFY_OTP_EVENT, data: _userData));
    }
  }

  void _proceed() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SetPasswordScreen(widget._emailId, _otp)));
  }
}

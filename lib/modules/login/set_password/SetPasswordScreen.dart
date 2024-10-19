import 'dart:convert';
import 'dart:ui';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'SetPasswordBloc.dart';

class SetPasswordScreen extends StatefulWidget {

  final String _emailId;
  final String _otp;

  SetPasswordScreen(this._emailId, this._otp);

  @override
  State<StatefulWidget> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  FocusNode _focusPassword;
  FocusNode _focusConfirmPassword;

  final _formKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _confirmPasswordKey = GlobalKey<FormFieldState>();

  SetPasswordBloc _bloc;
  String _password = "";
  String _confirmPassword = "";

  ValueNotifier<String> _apiResponseError = ValueNotifier("");

  @override
  void initState() {
    _bloc = SetPasswordBloc();
    _bloc.obsPassword.stream.listen((result) async {
      if (result.error != null) {
        _bloc.isLoading.value = false;
        _apiResponseError.value = result.error;
      } else {
        var _loginData = <String, dynamic>{
          'u': widget._emailId,
          'p': _password,
        };

        CommonBottomSheet.showSuccessWithLoaderBottomSheet(context, AppStrings.successText, AppStrings.setPasswordSuccessful);

        Future.delayed(Duration(seconds: 3),(){
          _bloc.event.add(EventModel(SetPasswordBloc.LOGIN_WITH_PASSWORD_EVENT, data: _loginData));
        });
      }
    });

    _bloc.obsLogin.stream.listen((result) async {
      if (result.error != null) {
        Navigator.pop(context);
        _apiResponseError.value = result.error;
      } else {
        if (result.data.ccId != null && (result.data.ccId != -1)) {
          _bloc.isLoading.value = true;
          await ConCubeUtils.createSessionAndLogin(
              ConCubeUtils.getCubeUserObject(result.data,
                  ccId: result.data.ccId),
              forceCreateSession: true);
          _bloc.isLoading.value = false;
          _proceed();
        } else {
          _bloc.isLoading.value = true;
          _bloc.event
              .add(EventModel(SetPasswordBloc.REGISTER_CC, data: result.data));
        }
      }
    });

    _bloc.obsRegisterCCId.stream.listen((result) {
      _bloc.isLoading.value = false;
      if (result.error != null) {
        _apiResponseError.value = result.error;
      } else {
        _proceed();
      }
    });

    _focusPassword = FocusNode();
    _focusConfirmPassword = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusPassword.dispose();
    _focusConfirmPassword.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/login_background.jpg"),
            fit: BoxFit.fill),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: BaseFormBodyUnsafe(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppDimensions.generalPadding,
                      AppDimensions.loginScreensTopBottomMargin,
                      AppDimensions.generalPadding,
                      AppDimensions.loginScreensTopBottomMargin),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.setPasswordLabel,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      SizedBox(height: AppDimensions.maxPadding),
                      Image.asset(
                        "assets/app_logo.png",
                        height: AppDimensions.loginScreensLogoSize,
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: TextFormField(
                          key: _passwordKey,
                          decoration: InputDecoration(
                              labelText: AppStrings.newPassword),
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          focusNode: _focusPassword,
                          obscureText: true,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onSaved: (value) => _password = value,
                          onFieldSubmitted: ValidationUtils.fieldNext(
                              context, _focusConfirmPassword),
                          validator: ValidationUtils.getPasswordValidator(
                              context,
                              errorText: AppStrings.enterNewPassword),
                        ),
                      ),
                      SizedBox(
                        height: AppDimensions.generalPadding,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: TextFormField(
                          key: _confirmPasswordKey,
                          decoration: InputDecoration(
                              labelText: AppStrings.confirmPassword),
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          focusNode: _focusConfirmPassword,
                          obscureText: true,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onSaved: (value) => _confirmPassword = value,
                          validator: ValidationUtils.getPasswordValidator(
                              context,
                              errorText: AppStrings.enterConfirmPassword),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.errorTextColor),
                                ),
                              ),
                            );
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

  Widget _getButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _processForm();
            },
            child: Text(AppStrings.submitLabel),
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
      if (_password.compareTo(_confirmPassword) != 0) {
        _apiResponseError.value = AppStrings.confirmPasswordError;
      } else {
        _apiResponseError.value = "";

        var _content = new Utf8Encoder().convert(_password);
        var _digest = crypto.sha512.convert(_content);
        var _sha512Pass = _digest;

        var _userData = <String, dynamic>{
          'lfv': widget._emailId,
          'k': widget._otp,
          'p': _password,
        };

        _bloc.isLoading.value = true;
        _bloc.event.add(
            EventModel(SetPasswordBloc.PASSWORD_EVENT, data: _userData));
      }
    }
  }

  void _proceed() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen()),
        ModalRoute.withName(""));
  }
}

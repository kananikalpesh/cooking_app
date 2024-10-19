import 'dart:ui';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/login/verify_otp/VerifyOtpScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ForgotPasswordBloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String _emailId;

  ForgotPasswordScreen(this._emailId);

  @override
  State<StatefulWidget> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  FocusNode _focusEmail;

  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();

  ForgotPasswordBloc _bloc;
  String _email = "";

  var _emailEdit = new TextEditingController();
  ValueNotifier<String> _apiResponseError = ValueNotifier("");
  
  @override
  void initState() {
    _bloc = ForgotPasswordBloc();
    _bloc.obsForgotPassword.stream.listen((result) {
      if (result.error != null) {
        _apiResponseError.value = result.error;
      } else {
        _proceed();
      }
    });

    _focusEmail = FocusNode();
    _emailEdit.text = widget._emailId;
    super.initState();
  }

  @override
  void dispose() {
    _focusEmail.dispose();
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
                          AppStrings.forgotPassword,
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
                        //margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                        child: TextFormField(
                          key: _emailKey,
                          decoration: InputDecoration(
                              labelText: AppStrings.emailId),
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          focusNode: _focusEmail,
                          onSaved: (value) => _email = value,
                          validator: ValidationUtils.getEmailAddressValidator(context),
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
                      SizedBox(
                        height: AppDimensions.maxPadding,
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppStrings.rememberPass, style: Theme.of(context).textTheme.subtitle2,),
                            SizedBox(width: 10,),
                            Text(AppStrings.signInLabel, style: Theme.of(context).textTheme.subtitle1.apply(
                              decoration: TextDecoration.underline,
                            ),),
                          ],
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
      _apiResponseError.value = "";

      var _userData = <String, dynamic>{
        'lfv': _email,
      };

      _bloc.event.add(EventModel(ForgotPasswordBloc.FORGOT_PASSWORD_EVENT, data: _userData));
    }
  }

  void _proceed() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VerifyOtpScreen(_email),),);
  }
}

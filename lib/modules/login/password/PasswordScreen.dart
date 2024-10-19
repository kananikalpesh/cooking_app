import 'dart:convert';
import 'dart:ui';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/modules/login/forgot_password/ForgotPasswordScreen.dart';
import 'package:cooking_app/modules/login/register/RegisterScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'PasswordBloc.dart';

class PasswordScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  FocusNode _focusPassword;
  FocusNode _focusEmailId;

  final _formKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();

  PasswordBloc _bloc;
  String _password = "";
  String _email = "";

  ValueNotifier<String> _apiResponseError = ValueNotifier("");

  @override
  void initState() {
    _bloc = PasswordBloc();
    _bloc.obsPassword.stream.listen((result) async {
      if (result.error != null) {
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
              .add(EventModel(PasswordBloc.REGISTER_CC, data: result.data));
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
    _focusEmailId = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusPassword.dispose();
    _focusEmailId.dispose();
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
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(AppStrings.signInLabel,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      SizedBox(height: AppDimensions.maxPadding),
                      Image.asset(
                        "assets/app_logo.png",
                        height: AppDimensions.loginScreensLogoSize,
                      ),
                      Expanded(child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: 20
                        ),
                      )),
                      /*RoleSelector((value) {
                        _selectedRole.value = value.index;
                      }),
                      SizedBox(height: AppDimensions.maxPadding),*/
                      Container(
                        //margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                        child: TextFormField(
                          key: _emailKey,
                          decoration: InputDecoration(
                              labelText: AppStrings.emailId),
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          focusNode: _focusEmailId,
                          onSaved: (value) => _email = value,
                          onFieldSubmitted: ValidationUtils.fieldNext(context, _focusPassword),
                          validator: ValidationUtils.getEmailAddressValidator(context),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                        child: TextFormField(
                          key: _passwordKey,
                          decoration: InputDecoration(
                              labelText: AppStrings.passwordButtonLabel),
                          maxLines: 1,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          focusNode: _focusPassword,
                          obscureText: true,
                          onSaved: (value) => _password = value,
                          validator: ValidationUtils.getPasswordValidator(context),
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
                        height: AppDimensions.generalPadding,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10,),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                _apiResponseError.value = "";
                                _goTo(RegisterScreen());
                              },
                              child: Text(AppStrings.newUserLabel,
                                style: Theme.of(context).textTheme.subtitle1.apply(
                                  decoration: TextDecoration.underline,),),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _apiResponseError.value = "";
                                _goTo(ForgotPasswordScreen(_email,));
                              },
                              child: Text(AppStrings.forgotYourPass,
                                style: Theme.of(context).textTheme.subtitle1.apply(
                                          decoration: TextDecoration.underline,),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
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
            child: Text(AppStrings.signInLabel),
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

  _goTo(Widget screen){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen)).then((value){
      _formKey.currentState.reset();
      setState(() {});
    });
  }

  _processForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _apiResponseError.value = "";

      var _content = new Utf8Encoder().convert(_password);
      var _digest = crypto.sha512.convert(_content);
      var _sha512Pass = _digest;

      var _userData = <String, dynamic>{
        'u': _email,
        'p': _password,
        //'Password': _sha512Pass,
      };

      _bloc.event.add(EventModel(PasswordBloc.PASSWORD_EVENT, data: _userData));
    }
  }

  void _proceed(){
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen()),
        ModalRoute.withName(""));
  }
}

import 'dart:ui';

import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/modules/login/password/PasswordScreen.dart';
import 'package:cooking_app/modules/login/register/CountryListBottomSheet.dart';
import 'package:cooking_app/modules/login/role_selector/RoleSelector.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'RegisterBloc.dart';

class RegisterScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FocusNode _focusName;
  FocusNode _focusEmailId;
  FocusNode _focusPassword;
  FocusNode _focusConfirmPassword;

  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _confirmPasswordKey = GlobalKey<FormFieldState>();
  var _countryController = new TextEditingController();

  RegisterBloc _bloc;
  String _name = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  String _countryName = "";
  List<String> countryList = [];

  ValueNotifier<String> _commonError = ValueNotifier("");
  ValueNotifier<int> _selectedRole = ValueNotifier(AppConstants.ROLE_COOK);

  ValueNotifier<bool> _isAboveAge = ValueNotifier(false);

  @override
  void initState() {
    _bloc = RegisterBloc();
    _bloc.obsRegister.stream.listen((result) {
      if (result.error != null) {
        _bloc.isLoading.value = false;
        _commonError.value = result.error;
      } else {
        var _loginData = <String, dynamic>{
          'u': _email,
          'p': _password,
        };

        CommonBottomSheet.showSuccessWithLoaderBottomSheet(context, AppStrings.successText, AppStrings.registrationSuccessful);

        Future.delayed(Duration(seconds: 3),(){
          _bloc.event.add(EventModel(RegisterBloc.PASSWORD_EVENT, data: _loginData));
        });
      }
    });

    _bloc.obsPassword.stream.listen((result) async {
      if (result.error != null) {
        Navigator.pop(context);
        _commonError.value = result.error;
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
              .add(EventModel(RegisterBloc.REGISTER_CC, data: result.data));
        }
      }
    });

    _bloc.obsRegisterCCId.stream.listen((result) {
      _bloc.isLoading.value = false;
      if (result.error != null) {
        _commonError.value = result.error;
      } else {
        _proceed();
      }
    });

    _bloc.obsCountryList.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else{
        countryList = result.data;
      }
    });
    
    _countryController.text = "";
    _bloc.event.add(EventModel(RegisterBloc.GET_COUNTRY_LIST_EVENT));

    _focusName = FocusNode();
    _focusEmailId = FocusNode();
    _focusPassword = FocusNode();
    _focusConfirmPassword = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _focusName.dispose();
    _focusEmailId.dispose();
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
            image: AssetImage("assets/login_background.jpg"), fit: BoxFit.fill
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: BaseFormBodyUnsafe(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_registrationUI()],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _registrationUI(){
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: AppDimensions.generalPadding, top: AppDimensions.loginScreensTopBottomMargin,
            right: AppDimensions.generalPadding, bottom: AppDimensions.generalTopPadding),
        child: Form(
            key: _formKey,
          child: Column(
            children: <Widget>[
              Text(AppStrings.signUpLabel, style: Theme.of(context).textTheme.headline4),
              SizedBox(height: AppDimensions.generalPadding),
              Image.asset("assets/app_logo.png", height: AppDimensions.loginScreensLogoSize,),
              Expanded(flex: 1, child: Container(),),
              Container(
                margin: EdgeInsets.only(top: AppDimensions.generalMinPadding),
                child: TextFormField(
                  key: _nameKey,
                  decoration: InputDecoration(labelText: AppStrings.nameLabel,),
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  focusNode: _focusName,
                  onSaved: (value) => _name = value,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z ]+"))
                  ],
                  onFieldSubmitted: ValidationUtils.fieldNext(context, _focusEmailId),
                  validator: ValidationUtils.getEmptyValidator(context, AppStrings.enterName),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: AppDimensions.generalPadding),
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
                      errorText: AppStrings.registerEnterPassword),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: AppDimensions.generalPadding),
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
              SizedBox(
                height: AppDimensions.generalPadding,
              ),
              RoleSelector((value) {
                _selectedRole.value = value;
              }),
              ValueListenableProvider<bool>.value(
                value: _bloc.isLoadingForCountries,
                child: Consumer<bool>(
                  builder: (context, isLoading, child){
                    return Container(
                      margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: Column(
                        children: [
                          TextFormField(
                            onTap: () async {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              if (countryList.isEmpty){
                                _bloc.event.add(EventModel(RegisterBloc.GET_COUNTRY_LIST_EVENT));
                              } else {
                                CountryListBottomSheet.showItemSelectionSheet(context, AppStrings.selectCountry, countryList).then((value) {
                                  if(value != null){
                                    _countryName = (value as String);
                                    _countryController.text = (value as String);
                                  }
                                });
                              }
                            },
                            controller: _countryController,
                            decoration: InputDecoration(labelText: AppStrings.selectCountry,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(AppDimensions.generalPadding),
                                child: isLoading ? SizedBox(child: CircularProgressIndicator(strokeWidth: 2.0,),
                                  width: 5, height: 5,)
                                    : SizedBox(child: Icon(Icons.arrow_drop_down_outlined,
                                  color: Theme.of(context).accentColor,), width: 5, height: 5,),
                              ),
                            ),
                            maxLines: 1,
                            autofocus: false,
                            enableInteractiveSelection: false,
                            showCursor: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            onSaved: (value) {},
                            validator: ValidationUtils.getEmptyValidator(context, AppStrings.selectCountryError),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: AppDimensions.largeTopBottomPadding,),
              GestureDetector(
                child: Row(
                  children: [
                    ValueListenableProvider<bool>.value(
                      value: _isAboveAge,
                      child: Consumer<bool>(
                        builder: (context, isChecked, child){
                          return isChecked ? Icon(Icons.check_box_outlined)
                              : Icon(Icons.check_box_outline_blank);
                        },
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text(AppStrings.aboveAgeLabel, style: Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
                onTap: (){
                  _isAboveAge.value = !(_isAboveAge.value);
                },
              ),
              ValueListenableProvider<String>.value(
                value: _commonError,
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
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyText1.apply(
                              fontStyle: FontStyle.italic,
                              color: AppColors.errorTextColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: AppDimensions.largeTopBottomPadding,
              ),
              ValueListenableProvider<bool>.value(
                value: _bloc.isLoading,
                child: Consumer<bool>(
                  builder: (context, loading, child) {
                    return (loading) ? _getLoaderWidget() : _getButton();
                  },
                ),
              ),
              SizedBox(
                height: AppDimensions.maxPadding,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PasswordScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.maxPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.alreadyAccount, style: Theme.of(context).textTheme.subtitle2,),
                      SizedBox(width: 10,),
                      Text(AppStrings.signInLabel, style: Theme.of(context).textTheme.subtitle1.apply(
                        decoration: TextDecoration.underline,
                      ),),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 2, child: Container(),),
            ],
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
            child: Text(AppStrings.signUpLabel),
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

      final String timezone = await FlutterNativeTimezone.getLocalTimezone();
      if (_password.compareTo(_confirmPassword) != 0) {
        _commonError.value = AppStrings.registerConfirmPasswordError;
        return;
      } else if (!_isAboveAge.value){
        _commonError.value = AppStrings.checkAgeForRegister;
        return;
      }

      _commonError.value = "";

      var _userData = <String, dynamic>{
        "first_name": _name,
        "last_name": _name,
        "email": _email,
        "password": _password,
        "password_confirmation": _confirmPassword,
        "role": _selectedRole.value,
        "is_13_or_older_age": _isAboveAge.value,
        "timezone": timezone,
        "country": _countryName
      };
      _bloc.event.add(EventModel(RegisterBloc.REGISTER_EVENT, data: _userData));
    } else {
      if (!_isAboveAge.value){
        _commonError.value = AppStrings.checkAgeForRegister;
      } else {
        _commonError.value = "";
      }
    }
  }

  void _proceed(){
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen()),
        ModalRoute.withName(""));
  }

}

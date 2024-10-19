
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/user/profile/change_password/ChangePasswordBloc.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChangePasswordBottomSheet{

  static void showChangePassSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.generalBottomSheetRadius),
                topRight: Radius.circular(AppDimensions.generalBottomSheetRadius),
              ),
              child: Container(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, top: AppDimensions.generalPadding, bottom: AppDimensions.maxPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(AppStrings.changePass, style: Theme.of(context).textTheme.subtitle2.apply(fontWeightDelta: -1, fontSizeDelta: 4, color: Theme.of(context).accentColor),),
                    SizedBox(height: AppDimensions.maxPadding,),
                    _BottomWidget(),
                  ],
                ),
              ),),
            ),
          );
        });
  }
}

class _BottomWidget extends StatefulWidget {

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<_BottomWidget> {

  ChangePasswordBloc _bloc;

  ValueNotifier<String> _errorMessage = ValueNotifier("");
  final _formKey = GlobalKey<FormState>();

  FocusNode _focusOldPassword;
  FocusNode _focusNewPassword;

  final _oldPasswordKey = GlobalKey<FormFieldState>();
  final _newPasswordKey = GlobalKey<FormFieldState>();

  String _oldPassword = "";
  String _newPassword = "";
  
  @override
  void initState() {
    _bloc = ChangePasswordBloc();

    _bloc.obsChangePass.stream.listen((result) {
      if (result.error != null) {
        _errorMessage.value = result.error;
      } else {
        Navigator.of(context).pop();
      }
    });

    _focusOldPassword = FocusNode();
    _focusNewPassword = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusOldPassword.dispose();
    _focusNewPassword.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 5),
              child: TextFormField(
                key: _oldPasswordKey,
                decoration: InputDecoration(
                    labelText: AppStrings.oldPassword),
                maxLines: 1,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autofocus: false,
                focusNode: _focusOldPassword,
                obscureText: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                onSaved: (value) => _oldPassword = value,
                onFieldSubmitted: ValidationUtils.fieldNext(
                    context, _focusNewPassword),
                validator: ValidationUtils.getPasswordValidator(
                    context,
                    errorText: AppStrings.enterOldPassword),
              ),
            ),
            SizedBox(
              height: AppDimensions.generalPadding,
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: TextFormField(
                key: _newPasswordKey,
                decoration: InputDecoration(
                    labelText: AppStrings.newPassword),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                autofocus: false,
                focusNode: _focusNewPassword,
                obscureText: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                onSaved: (value) => _newPassword = value,
                validator: ValidationUtils.getPasswordValidator(
                    context,
                    errorText: AppStrings.enterNewPassword),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ValueListenableProvider<String>.value(
                value: _errorMessage,
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
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.errorTextColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: AppDimensions.generalPadding,
            ),
            ValueListenableProvider<bool>.value(
              value: _bloc.isLoading,
              child: Consumer<bool>(
                builder: (context, loading, child) {
                  return (loading) ? _getLoaderWidget() : _getSubmitButton();
                },
              ),
            ),
          ],
        ),
      ),
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

  Widget _getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  if(_oldPassword == _newPassword){
                    _errorMessage.value = AppStrings.oldAndNewPasswordError;
                    return;
                  }

                  _errorMessage.value = "";

                  Map<String, dynamic> data = <String, dynamic>{
                    "u": AppData.user.email,
                    "o": _oldPassword,
                    "p": _newPassword,
                  };
                  _bloc.event.add(EventModel(ChangePasswordBloc.CHANGE_PASSWORD, data: data));
                }
              },
              child: Text(AppStrings.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
  
}
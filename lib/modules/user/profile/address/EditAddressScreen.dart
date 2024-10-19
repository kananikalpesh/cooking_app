
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/login/register/CountryListBottomSheet.dart';
import 'package:cooking_app/modules/user/profile/address/EditAddressBloc.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditAddressScreen extends StatefulWidget {

  final AddressModel addressModel;
  final bool isIncomplete;
  final String errorMsgFromBackend;

  EditAddressScreen({this.addressModel, this.isIncomplete = false, this.errorMsgFromBackend});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {

  EditAddressBloc _bloc;

  String _line1;
  String _line2;
  String _country;
  String _state;
  String _city;
  String _zipCode;

  final _formKey = GlobalKey<FormState>();
  FocusNode _focusLine1;
  FocusNode _focusLine2;
  FocusNode _focusState;
  FocusNode _focusCity;
  FocusNode _focusZipCode;

  var _line1Controller = new TextEditingController();
  var _line2Controller = new TextEditingController();
  var _countryController = new TextEditingController();
  var _stateController = new TextEditingController();
  var _cityController = new TextEditingController();
  var _zipCodeController = new TextEditingController();

  List<String> countryList = [];

  ValueNotifier<bool> _showErrorTitle = ValueNotifier(false);

  @override
  void initState() {

    _bloc = EditAddressBloc();

    _bloc.obsUpdateAddress.stream.listen((result) async {
      if (result.error != null) {
        _bloc.isAddressUpdating.value = false;
        CommonBottomSheet.showErrorBottomSheet(context,result);
      } else{
        _bloc.isAddressUpdating.value = false;
        var address = AddressModel(id: AppData.user?.addressModel?.id, userId: AppData.user?.id,
            line1: _line1, line2: _line2, city: _city, state: _state, zipCode: _zipCode, country: _country);
        Navigator.pop(context, address);
      }
    });

    _line1Controller.text = widget.addressModel?.line1 ?? "";
    _line2Controller.text = widget.addressModel?.line2 ?? "";
    _countryController.text = widget.addressModel?.country ?? "";
    _stateController.text = widget.addressModel?.state ?? "";
    _cityController.text = widget.addressModel?.city ?? "";
    _zipCodeController.text = widget.addressModel?.zipCode ?? "";
    _country = widget.addressModel?.country ?? "";

    _bloc.obsCountryList.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else{
        countryList = result.data;
      }
    });

    _bloc.event.add(EventModel(EditAddressBloc.GET_COUNTRIES_EVENT));

    _focusLine1 = FocusNode();
    _focusLine2 = FocusNode();
    _focusState = FocusNode();
    _focusCity = FocusNode();
    _focusZipCode = FocusNode();

    super.initState();

    if(widget.isIncomplete){
      _showErrorTitle.value = true;
      Future.delayed(Duration(microseconds: 100), (){
        CommonBottomSheet.showSuccessBottomSheet(context, widget.errorMsgFromBackend ?? AppStrings.updateAddressDesc,
            title: AppStrings.updateAddressTitle);
      });
    }

  }


  @override
  Widget build(BuildContext context) {

    _line1Controller.selection = TextSelection.fromPosition(TextPosition(offset:_line1Controller.text.length));
    _line2Controller.selection = TextSelection.fromPosition(TextPosition(offset:_line2Controller.text.length));
    _stateController.selection = TextSelection.fromPosition(TextPosition(offset:_stateController.text.length));
    _cityController.selection = TextSelection.fromPosition(TextPosition(offset:_cityController.text.length));
    _zipCodeController.selection = TextSelection.fromPosition(TextPosition(offset:_zipCodeController.text.length));

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editAddress)),
      body: BaseFormBodyUnsafe(
        child: SingleChildScrollView(
          child: mainContainerWidget(),
        ),
      ),
    );
  }

  Widget mainContainerWidget(){
    return Column(
      children: [
        Container(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.maxPadding, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
              child: Column(
                children: <Widget>[
                  ValueListenableProvider<bool>.value(
                    value: _showErrorTitle,
                    child: Consumer<bool>(
                      builder: (context, showTitle, child){
                        return (!showTitle) ? Container()
                            : Text(AppStrings.addressNote,
                          style: Theme.of(context).textTheme.bodyText2.apply(
                              fontStyle: FontStyle.italic
                          ), textAlign: TextAlign.center,);
                      },
                    ),
                  ),
                  Container(
                    margin:
                    EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: TextFormField(
                      controller: _line1Controller,
                      decoration:
                      InputDecoration(labelText: AppStrings.line1),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      focusNode: _focusLine1,
                      onFieldSubmitted: ValidationUtils.fieldNext(
                          context, _focusLine2),
                      onSaved: (value) => _line1 = value,
                      validator: ValidationUtils.getEmptyValidator(
                          context, AppStrings.enterLine1),
                    ),
                  ),
                  Container(
                    margin:
                    EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: TextFormField(
                      controller: _line2Controller,
                      decoration:
                      InputDecoration(labelText: AppStrings.line2),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      focusNode: _focusLine2,
                      onFieldSubmitted: ValidationUtils.fieldNext(
                          context, _focusState),
                      onSaved: (value) => _line2 = value,
                    ),
                  ),
                  ValueListenableProvider<bool>.value(
                    value: _bloc.isLoadingForCountries,
                    child: Consumer<bool>(
                      builder: (context, isLoading, child){
                        return Container(
                          margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                          child: TextFormField(
                            onTap: () async {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              if (countryList.isEmpty){
                                _bloc.event.add(EventModel(EditAddressBloc.GET_COUNTRIES_EVENT));
                              } else {
                                CountryListBottomSheet.showItemSelectionSheet(context, AppStrings.selectCountry, countryList).then((value) {
                                  if(value != null){
                                    _country = (value as String);
                                    _countryController.text = (value as String);
                                  }
                                });
                              }
                            },
                            controller: _countryController,
                            decoration: InputDecoration(labelText: AppStrings.country,
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
                        );
                      },
                    ),
                  ),
                  Container(
                    margin:
                    EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: TextFormField(
                      controller: _stateController,
                      decoration:
                      InputDecoration(labelText: AppStrings.state),
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      focusNode: _focusState,
                      onFieldSubmitted: ValidationUtils.fieldNext(
                          context, _focusCity),
                      onSaved: (value) => _state = value,
                      validator: ValidationUtils.getEmptyValidator(
                          context, AppStrings.enterState),
                    ),
                  ),
                  Container(
                    margin:
                    EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: TextFormField(
                      controller: _cityController,
                      decoration:
                      InputDecoration(labelText: AppStrings.city),
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      focusNode: _focusCity,
                      onFieldSubmitted: ValidationUtils.fieldNext(
                          context, _focusZipCode),
                      onSaved: (value) => _city = value,
                      validator: ValidationUtils.getEmptyValidator(
                          context, AppStrings.enterCity),
                    ),
                  ),
                  Container(
                    margin:
                    EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: TextFormField(
                      controller: _zipCodeController,
                      decoration:
                      InputDecoration(labelText: AppStrings.zipCode),
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      focusNode: _focusZipCode,
                      onSaved: (value) => _zipCode = value,
                      validator: ValidationUtils.getEmptyValidator(
                          context, AppStrings.enterZipCode),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
            right: AppDimensions.generalPadding, top: AppDimensions.generalPadding,
            bottom: AppDimensions.maxPadding,),
          child: Column(
            children: [
              ValueListenableProvider<bool>.value(
                  value: _bloc.isAddressUpdating,
                  child: Consumer<bool>(
                      builder: (context, isLoading, child){
                        return isLoading ? _getLoaderWidget() : _getSubmitButton();
                      })
              ),
            ],
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

  Widget _getSubmitButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _processForm(),
            child: Text(AppStrings.saveLabel,),
          ),
        ),
      ],
    );
  }

  _processForm(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      
      var userData = <String, dynamic>{
        //if (AppData.user?.addressModel?.id != null) "id" : AppData.user?.addressModel?.id,
        "user_id": AppData.user?.id ?? -1,
        "line1": _line1,
        "line2": _line2,
        "city": _city,
        "state": _state,
        "zip": _zipCode,
        "country": _country,
      };
      _bloc.isAddressUpdating.value = true;
      _bloc.event.add(EventModel(EditAddressBloc.UPDATE_ADDRESS_EVENT, data: userData));
    }
  }

  @override
  void dispose() {
    _focusLine1.dispose();
    _focusLine2.dispose();
    _focusState.dispose();
    _focusCity.dispose();
    _focusZipCode.dispose();
    super.dispose();
  }

}

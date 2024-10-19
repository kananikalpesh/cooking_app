
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';

typedef OnRoleSelected(int role);

class RoleSelector extends StatefulWidget {
  final OnRoleSelected callback;
  final int defaultSelection;

  const RoleSelector(this.callback, {this.defaultSelection = AppConstants.ROLE_COOK, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoleSelectorState(defaultSelection);
}

class _RoleSelectorState extends State<RoleSelector> {
  int _selectedRole;
  _RoleSelectorState(this._selectedRole);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(AppStrings.iAmLabel,
          style: Theme.of(context).textTheme.headline6.apply(
            color: Theme.of(context).accentColor,
            fontWeightDelta: 2,
          ),
        ),
        SizedBox(width: 10,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: AppDimensions.generalPadding),
                child: GestureDetector(
                  onTap: () => _setSelection(AppConstants.ROLE_COOK),
                  child: Container(
                    decoration: _boxDecoration(
                      _selectedRole == AppConstants.ROLE_COOK,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5,
                          bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: AppDimensions.generalMinPadding,
                                right: AppDimensions.generalMinPadding),
                            child: Offstage(
                              offstage: !(_selectedRole == AppConstants.ROLE_COOK),
                              child: Icon(Icons.done, color: Theme.of(context).accentColor, size: 30,),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Center(
                                  child: Text(AppStrings.roleCookLabel,
                                    style: _getTitleTextTheme(_selectedRole == AppConstants.ROLE_COOK),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 3,),
                                Text(
                                  AppStrings.roleCookDesc,
                                  style: _getDescTextTheme(_selectedRole == AppConstants.ROLE_COOK),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.only(left: AppDimensions.generalPadding),
                child: GestureDetector(
                  onTap: () => _setSelection(AppConstants.ROLE_USER),
                  child: Container(
                    decoration: _boxDecoration(
                      _selectedRole == AppConstants.ROLE_USER,
                    ),
                    //height: 45,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5,
                          bottom: 5),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: AppDimensions.generalMinPadding,
                                right: AppDimensions.generalMinPadding),
                            child: Offstage(
                              offstage: !(_selectedRole == AppConstants.ROLE_USER),
                              child: Icon(Icons.done, color: Theme.of(context).accentColor, size: 30,),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(AppStrings.roleNormalLabel,
                                    style: _getTitleTextTheme(_selectedRole == AppConstants.ROLE_USER),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 3,),
                                Text(
                                  AppStrings.roleNormalDesc,
                                  style: _getDescTextTheme(_selectedRole == AppConstants.ROLE_USER),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _getTitleTextTheme(bool isSelected) => 
      Theme.of(context).textTheme.subtitle1.apply(color: isSelected ? Theme.of(context).accentColor : AppColors.loginTabNotSelectedText);

  TextStyle _getDescTextTheme(bool isSelected) =>
      Theme.of(context).textTheme.bodyText2.apply(color: isSelected ? Theme.of(context).accentColor : AppColors.loginTabNotSelectedText);

  BoxDecoration _boxDecoration(bool isSelected) => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
    border: Border.all(color: isSelected ? Theme.of(context).accentColor : AppColors.loginTabNotSelectedBg,
      width: 2,)
  );

  void _setSelection(int userType) {
    widget.callback(userType);
    setState(() {
      _selectedRole = userType;
    });
  }
}

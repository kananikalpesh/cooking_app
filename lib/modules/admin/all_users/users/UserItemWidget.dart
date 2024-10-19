
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/admin/all_users/users/UserListBloc.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/other_user/OtherUserProfileScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef _UserDeleted(bool isDeleted);

class UserItemWidget extends StatefulWidget{

  final UserModel _userModel;
  final _UserDeleted _onAvailabilityDeleted;
  final UserListBloc _bloc;
  final int index;
  UserItemWidget(this.index, this._userModel, this._bloc, this._onAvailabilityDeleted);

  @override
  _UserItemWidgetState createState() => _UserItemWidgetState();
}

class _UserItemWidgetState extends State<UserItemWidget>{

  ValueNotifier<bool> isLoadingForDelete = ValueNotifier(false);

  @override
  void initState() {

    widget._bloc.obsDeleteUser.listen((result) {
      if (widget.index == widget._bloc.deleteLoadingIndex){
        isLoadingForDelete.value = false;
        widget._bloc.deleteLoadingIndex = -1;
        if (result.error != null) {
          CommonBottomSheet.showErrorBottomSheet(context, result);
        } else {
          widget._onAvailabilityDeleted(true);
        }
      }
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top:AppDimensions.generalTopPadding, bottom: AppDimensions.generalTopPadding),
          child: ListTile(
            onTap: (){
              SystemChrome.setEnabledSystemUIOverlays(
                  [SystemUiOverlay.bottom, SystemUiOverlay.top]);
              SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(userId: widget._userModel.id,))).then((value) {
                SystemChrome.setEnabledSystemUIOverlays(
                    [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                SystemChrome.setSystemUIOverlayStyle(
                    AppTheme.overlayStyleBottomTabBar);
              });
            },
            leading: CustomImageShapeWidget(
              50,
              50,
              50 / 2,
              CachedNetworkImage(
                //key: GlobalKey(),
                width: 50,
                height: 50,
                fit: BoxFit.fill,
                imageUrl: (widget._userModel?.userImage ?? ""),
                progressIndicatorBuilder: (context,
                    url, downloadProgress) =>
                    Image.asset(
                      "assets/loading_image.png",
                      fit: BoxFit.cover,
                    ),
                errorWidget:
                    (context, url, error) =>
                    Image.asset(
                      "assets/profile_user_default_icon.png",
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget._userModel.firstName,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 5,),
                Text(widget._userModel.email,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            trailing: ValueListenableProvider<bool>.value(value: isLoadingForDelete,
              child: Consumer<bool>(builder: (context, isLoading, child){
                return isLoading
                    ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator())
                    : GestureDetector(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: 0, color: AppColors.redBgButton),
                        color: AppColors.redBgButton,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Center(
                          child: Icon(Icons.delete, color: AppColors.white, size: 20,),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    CommonBottomSheet.showConfirmationBottomSheet(
                      context,
                      AppStrings.deleteButtonName,
                      AppStrings.deleteUserMsg,
                      AppStrings.deleteButtonName,
                      AppStrings.cancelButtonName,
                          () {
                        Navigator.of(context).pop();
                        isLoadingForDelete.value = true;
                        widget._bloc.deleteLoadingIndex = widget.index;
                        widget._bloc.event.sink.add(EventModel(
                            UserListBloc.DELETE_USER,
                            data: widget._userModel.id));
                      },
                    );
                  },
                );
              }),),
          ),
        ),
      ),
    );
  }

}


import 'package:cooking_app/modules/admin/all_users/cooks/CooksListScreen.dart';
import 'package:cooking_app/modules/admin/all_users/users/UsersListScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllUsersScreen extends StatefulWidget{
  final Key key;
  final bool isFlaggedUsers;

  AllUsersScreen(this.key, this.isFlaggedUsers) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => AllUsersScreenState();

}

class AllUsersScreenState extends State<AllUsersScreen>{

  GlobalKey _tabKey = GlobalKey();

  @override
  initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: Text((widget.isFlaggedUsers) ? AppStrings.flaggedUsers : AppStrings.allUsers),
            bottom: TabBar(
              indicatorColor: Theme.of(context).accentColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).accentColor,
              indicatorWeight: 4,
              labelStyle: Theme.of(context).textTheme.subtitle1.apply(
                  fontWeightDelta: 1,
                  fontSizeDelta: 1
              ),
              unselectedLabelColor: AppColors.black,
              unselectedLabelStyle: Theme.of(context).textTheme.subtitle2.apply(
                  fontSizeDelta: 2
              ),
              tabs: [
                Tab(text: AppStrings.cooksLabel,),
                Tab(text: AppStrings.usersLabel,)
              ],
            ),
          ),
          body: TabBarView(key: _tabKey,
            children: [
              CooksListScreen(widget.isFlaggedUsers),
              UsersListScreen(widget.isFlaggedUsers)
            ],
          ),
        ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}
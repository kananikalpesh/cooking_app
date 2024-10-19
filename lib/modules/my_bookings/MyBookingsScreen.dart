
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestScreen.dart';
import 'package:cooking_app/modules/my_bookings/past/PastBookingsScreen.dart';
import 'package:cooking_app/modules/my_bookings/upcoming/UpcomingBookingsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyBookingsScreen extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() => MyBookingsScreenState();

}

class MyBookingsScreenState extends State<MyBookingsScreen>{

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
            title: Text(AppStrings.myBookings),
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
                Tab(text: AppStrings.upcoming,),
                Tab(text: AppStrings.past,)
              ],
            ),
            actions: [
              Offstage(
                offstage: (AppData.user.role != AppConstants.ROLE_COOK),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child: GestureDetector(
                    onTap: (){
                      SystemChrome.setEnabledSystemUIOverlays(
                          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                          builder: (context) => MyRequestScreen()))
                          .then((value) {

                            if((value ?? false)){
                              setState(() {
                                _tabKey = GlobalKey();
                              });
                            }
                        SystemChrome.setEnabledSystemUIOverlays(
                            [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                        SystemChrome.setSystemUIOverlayStyle(
                            AppTheme.overlayStyleBottomTabBar);
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding,),
                          child: Center(child: Text(AppStrings.requests, style: Theme.of(context).textTheme.subtitle2.apply(
                            color: AppColors.white
                          ), textScaleFactor: 1.0,)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: TabBarView(key: _tabKey,
            children: [
              UpcomingBookingsScreen(),
              PastBookingsScreen()
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
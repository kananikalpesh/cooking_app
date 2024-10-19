
import 'package:cooking_app/modules/user/home/UserHomeScreen.dart';
import 'package:flutter/material.dart';

typedef ChangeWidget(Widget screen);

class HomeNavigationScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen>{
  Widget currentWidget;

  @override
  void initState() {
    currentWidget = UserHomeScreen((Widget screen){
      setState(() {
        currentWidget = screen;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: currentWidget,);
  }

}

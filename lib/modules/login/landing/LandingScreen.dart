
import 'package:cooking_app/modules/login/password/PasswordScreen.dart';
import 'package:cooking_app/modules/login/register/RegisterScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';

class LandingScreen extends StatefulWidget {

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/login_background.jpg"), fit: BoxFit.fill
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.maxPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //SizedBox(height: 20,),
              Expanded(
                child: Container(
                  /*decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(color: AppColors.black),
                  ),*/
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.maxPadding),
                    child: Column(
                      children: [
                        //SizedBox(height: 10,),
                        Image.asset("assets/app_logo.png", height: AppDimensions.loginScreensLogoSize,),
                        SizedBox(height: 20,),
                        Text(AppStrings.landingScreenMsg, style: Theme.of(context).textTheme.headline4.apply(color: Theme.of(context).accentColor),),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50,),
              Column(
                children: [
                  SizedBox(width: 190,
                    child: ElevatedButton(
                      onPressed: (){
                        _goTo(PasswordScreen());
                      },
                      child: Text(AppStrings.signInLabel,),
                    ),
                  ),
                  SizedBox(height: AppDimensions.generalPadding,),
                  SizedBox(width: 190,
                    child: ElevatedButton(
                      onPressed: (){
                        _goTo(RegisterScreen());
                      },
                      child: Text(AppStrings.newUserLabel,),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.maxPadding,),
            ],
          ),
        ),
      ),
    );
  }

  _goTo(Widget screen){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  void dispose() {
    super.dispose();
  }

}

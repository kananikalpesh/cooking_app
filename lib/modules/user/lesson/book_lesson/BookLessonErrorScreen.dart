
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';

class BookLessonErrorScreen extends StatelessWidget {
  final String message;

  BookLessonErrorScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.errorText),),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.generalPadding),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppDimensions.generalPadding),
                Image.asset(
                  "assets/app_logo.png",
                  height: AppDimensions.loginScreensLogoSize,
                ),
                SizedBox(height: AppDimensions.generalPadding),
                Text(AppStrings.stripeErrorTitle,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            Center(
              child: Text(message,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

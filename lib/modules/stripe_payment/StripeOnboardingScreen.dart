
import 'dart:io';

import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

//Response Handling ::
//True = Success
//False = Fail [Expired]
//Null = Cancel

class StripeOnboardingScreen extends StatefulWidget {
  final String url;
  final String returnUrl, refreshUrl;

  const StripeOnboardingScreen({Key key, this.url, this.returnUrl, this.refreshUrl}) : super(key: key);

  @override
  _StripeOnboardingScreenState createState() => _StripeOnboardingScreenState();
}

class _StripeOnboardingScreenState extends State<StripeOnboardingScreen> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(color: (Platform.isIOS) ? AppColors.white : AppColors.transparent,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.generalPadding),
                child: WebView(
                  initialUrl: widget.url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (webViewController) =>
                  _controller = webViewController,
                  onPageFinished: (String url) {},
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith(widget.returnUrl)) {
                      Navigator.of(context).pop(true);
                    } else if (request.url.startsWith(widget.refreshUrl)) {
                      Navigator.of(context).pop(false);
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              ),

              Positioned(right: 20, top: 30, child: GestureDetector(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          width: 0, color: Theme.of(context).accentColor),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Center(
                        child: Icon(Icons.close, color: AppColors.white, size: 20,),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),),
            ],
          ),
        ),
      ),
    );
  }

}
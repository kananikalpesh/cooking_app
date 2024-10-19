import 'dart:convert';

import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

//Response Handling ::
//True = Success
//False = Fail
//Null = Cancel

class StripePaymentScreen extends StatefulWidget {
  final String sessionId, clientId;
  final String apiKey;
  final String successUrl, failUrl;

  const StripePaymentScreen({Key key, this.sessionId, this.apiKey, this.clientId, this.successUrl, this.failUrl}) : super(key: key);

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.generalPadding),
            child: WebView(
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (webViewController) =>
              _controller = webViewController,
              onPageFinished: (String url) {
                if (url == initialUrl) {
                  _redirectToStripe(widget.sessionId, widget.apiKey, widget.clientId);
                }
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith(widget.successUrl)) {
                  Navigator.of(context).pop(true);
                } else if (request.url.startsWith(widget.failUrl)) {
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
        ],),
      ),
    );
  }

   String get initialUrl => 'data:text/html;base64,${base64Encode(Utf8Encoder().convert(kStripeHtmlPage))}';

  Future<void> _redirectToStripe(String sessionId, String apiKey, String clientId) async {
    final redirectToCheckoutJs = '''
    var stripe = Stripe(\'$apiKey\', {
  stripeAccount: '$clientId',
});
stripe.redirectToCheckout({
  sessionId: '$sessionId'
}).then(function (result) {
  result.error.message = 'Error'
});
''';

    try {
      await _controller.evaluateJavascript(redirectToCheckoutJs);
    } on PlatformException catch (e) {
      if (!e.details.contains(
          'JavaScript execution returned a result of an unsupported type')) {
        rethrow;
      }
    }
  }
}

const kStripeHtmlPage = '''
<!DOCTYPE html>
<html>
<script src="https://js.stripe.com/v3/"></script>
<head><title>Stripe checkout</title></head>
<body>
</body>
</html>
''';
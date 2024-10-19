
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScreen extends StatefulWidget {
  final String appBarTitle;
  final String link;

  WebScreen(this.appBarTitle, this.link);

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  var _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle),),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget.link,
            navigationDelegate: (NavigationRequest request) {
              if (!request.url.startsWith(widget.link)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          _isLoading ? Center(child: CircularProgressIndicator(),) : Container(),
        ],
      ),
    );
  }
}

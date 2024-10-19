import 'dart:async';
import 'dart:io';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

const _TAG = "PdfViewerScreen";
class PdfViewerScreen extends StatefulWidget {

  final String title;
  final String url;
  final bool isLocalFile;
  PdfViewerScreen(this.title, this.url, {this.isLocalFile = false});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {

  File _pdfFile;
  int _pages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();

  @override
  void initState() {
    if(widget.isLocalFile){
      _pdfFile = File(widget.url);
    }else getFileFromNetwork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          children: <Widget>[

            (_pdfFile==null) ? Container() : PDFView(
              filePath: _pdfFile.path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              onRender: (_pages) {
                setState(() {
                  this._pages = _pages;
                  _isReady = true;
                });
              },
              onError: (error) {
                LogManager().log(_TAG, "onError", "Getting error in pdf viewer screen.", e: error);
                setState(() {
                  _errorMessage = error.toString();
                });
              },
              onPageError: (page, error) {
                LogManager().log(_TAG, "onPageError", "Getting error in pdf viewer screen.", e: error);
                setState(() {
                  _errorMessage = '$page: ${error.toString()}';
                });

              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onPageChanged: (int page, int total) {

                setState(() {
                  _currentPage = page;
                });
              },
            ),
            _errorMessage.isEmpty
                ? !_isReady
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Container()
                : Center(
              child: Text(_errorMessage),
            ),

            Positioned(
              right: 20,
              bottom: 32,
              child: FutureBuilder<PDFViewController>(
                future: _controller.future,
                builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                  if (snapshot.hasData) {
                    return Text("${_currentPage+1} / $_pages");
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
    );
  }

  getFileFromNetwork() async {
    try {
      var response = await http.get(Uri.parse(widget.url));
      if(response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS){
        var bytes = response.bodyBytes;
        var dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/pdfSampleOnline.pdf");
        _pdfFile = await file.writeAsBytes(bytes);
        setState(() {
        });
      }else{
        LogManager().log(_TAG, "getFileFromNetwork", "Getting error while fetching file from network- ${response.statusCode}");
        setState(() {
          _errorMessage = ServerConnectionHelper.getDefaultHttpError(response.statusCode);
        });
      }

    } catch (e) {
      LogManager().log(_TAG, "getFileFromNetwork", "Getting exception while fetching file from network.", e: e);
      _errorMessage = AppStrings.errorOnOpeningPdfMsg;
      setState(() {});
    }
  }
}

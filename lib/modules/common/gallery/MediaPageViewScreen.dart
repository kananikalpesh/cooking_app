import 'dart:io';

import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/modules/common/gallery/viewers/ImageViewerScreen.dart';
import 'package:cooking_app/modules/common/gallery/viewers/VideoViewerScreen.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppColors.dart';


class MediaPageViewScreen extends StatefulWidget {
  final List<AttachmentModel> attachmentList;
  final int startIndexAt;

  MediaPageViewScreen(this.attachmentList, this.startIndexAt);

  @override
  _MediaPageViewState createState() => _MediaPageViewState();
}

class _MediaPageViewState extends State<MediaPageViewScreen> {
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.startIndexAt);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
    children: <Widget>[
      PageView.builder(
          controller: _pageController,
          itemCount: widget.attachmentList.length,
          // ignore: missing_return
          itemBuilder: (context, index) {
            switch (widget.attachmentList[index].fileType) {
              case AppConstants.IMAGE:
                return ImageViewerScreen(
                    widget.attachmentList[index].filePath,
                    isLocalFile: widget.attachmentList[index].id == null,
                    fromGallery: true);
              case AppConstants.VIDEO:
                return VideoViewerScreen(
                    widget.attachmentList[index].filePath,
                    isLocalFile: widget.attachmentList[index].id == null,
                    fromGallery: true);
              /*case AttachmentFileType.Document:
                return Container(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PdfViewerScreen(AppStrings.pdfViewerTitle,
                                widget.attachmentList[index].filePath))).then((value){
                          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
                          SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleGallery);
                        });
                      },
                      child: Stack(
                        children: <Widget>[
                          Image.asset(
                            "assets/general_pdf.png",
                            color: AppColors.white,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),

                        ],
                      ),
                    ),
                  ),
                );*/
            }
          }),
      Positioned(
        top: 32,
        left: 10,
        child: Container(
          color: Colors.transparent,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            iconSize: 30,
            icon: Center(
                child: Icon(
                  (Platform.isIOS) ? Icons.arrow_back_ios : Icons.arrow_back,
              color: AppColors.white,
            )),
          ),
        ),
      ),
    ],
      ),
    );
  }
}


import 'dart:io';

import 'package:cooking_app/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerScreen extends StatefulWidget {

  final String url;
  final bool fromGallery;
  final bool isLocalFile;
  ImageViewerScreen(this.url, {this.fromGallery = false, this.isLocalFile = false});

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children:[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: (widget.isLocalFile)
                  ? Image.file(File(widget.url),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,)
                  : CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                imageUrl: widget.url,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Image.asset(
                      "assets/loading_image.png",
                      fit: BoxFit.contain,
                    ),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/error_image.png",
                  fit: BoxFit.contain,
                  color: AppColors.grayColor,
                ),
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 10,
            child: Offstage(
              offstage: widget.fromGallery,
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
          ),
        ],
      ),
    );
  }
}

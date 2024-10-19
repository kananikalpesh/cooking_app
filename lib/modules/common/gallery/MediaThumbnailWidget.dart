
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaThumbnailWidget extends StatefulWidget {
  //final String url;
  //final AttachmentFileType fileType;
  final double size;
  final AttachmentModel imageModel;
  MediaThumbnailWidget.lessonImageModel(this.imageModel, this.size,);

  @override
  State<StatefulWidget> createState() => MediaThumbnailState();
}

class MediaThumbnailState extends State<MediaThumbnailWidget> {
  ValueNotifier<String> videoThumbnail = ValueNotifier("");

  String fileType;

  @override
  void initState() {
    fileType = widget.imageModel.fileType;
    // if (fileType.index == AttachmentFileType.Video.index) {
    //   getThumbnail(context);
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.generalMinPadding)),
        child: getMediaView(),
      ),
      Positioned(
          top: 0,
          left: 0,
          width: widget.size,
          height: widget.size/1.5,
          child: Container(
            width: widget.size,
            height: widget.size/1.5,
            decoration: BoxDecoration(
              //color: AppColors.black.withOpacity(0.4),
              borderRadius: BorderRadius.all(
                  Radius.circular(AppDimensions.generalMinPadding)),
            ),
            child: Center(
              child: Container(
                child: Icon(Icons.play_circle_outline,
                    color: ((fileType != AppConstants.VIDEO))
                        ? Colors.transparent
                        : Colors.white,
                    size: 50.0),
              ),
            ),
          )),
    ]);
  }

  getThumbnail(BuildContext context) async {
    videoThumbnail.value = await VideoThumbnail.thumbnailFile(
      video: widget.imageModel.filePath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      //maxWidth: widget.size.toInt(),
      maxHeight: (widget.size/1.5).toInt(),
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 70,
    );
  }

  Widget getMediaView() {
    /*if (fileType.index == AttachmentFileType.Video.index) {
      return ValueListenableProvider<String>.value(
        value: videoThumbnail,
        child: Consumer<String>(
          builder: (context, value, index) {
            return Container(
                height: widget.size/1.2,
                width: widget.size,
                decoration: BoxDecoration(border: Border.all(color: AppColors.backgroundGrey300,), color: AppColors.backgroundGrey300,),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.generalMinPadding)),
                  child: ((value?.isEmpty ?? true))
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : Image.file(
                  File(value),
                  height: widget.size/1.2,
                  width: widget.size,
                  fit: BoxFit.cover,
                ),));
          },
        ),
      );
    } else */
    if (fileType == AppConstants.IMAGE ||
        fileType == AppConstants.VIDEO) {
      return Container(
        height: widget.size/1.2,
        width: widget.size,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.backgroundGrey300,
          ),
          color: AppColors.backgroundGrey300,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.generalMinPadding)),
          child: CachedNetworkImage(
            width: widget.size,
            height: widget.size/1.2,
            fit: BoxFit.fill,
            imageUrl: (widget.imageModel.thumbnailPath != null)
                ? widget.imageModel.thumbnailPath
                : widget.imageModel.filePath,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Image.asset(
              "assets/loading_image.png",
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => ClipRRect(
              //borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Image.asset(
                "assets/error_image.png",
                fit: BoxFit.cover,
              ),),),),
      );
    } else {

      return Container(
        height: widget.size/1.2,
        width: widget.size,
        decoration: BoxDecoration(border: Border.all(color: AppColors.backgroundGrey300,), color: AppColors.backgroundGrey300,),
        child: Center(
          child: ClipRRect(borderRadius: BorderRadius.all(
              Radius.circular(AppDimensions.generalMinPadding)),
            child: Image.asset(
            "assets/general_pdf.png",
            color: AppColors.black,
            width: widget.size / 2,
            height: (widget.size/1.2) / 2,
          ),),
        ),
      );
    }
  }
}
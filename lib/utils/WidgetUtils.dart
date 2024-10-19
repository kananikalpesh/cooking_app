import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'AppDimensions.dart';

class WidgetUtils {
  static double renderTextParagraphHeight(
      {@required BuildContext context,
      @required TextStyle textStyle,
      @required String text}) {
    final constraints = BoxConstraints(
      maxWidth: (MediaQuery.of(context).size.width -
          (2 * AppDimensions.generalPadding)),
    );

    RenderParagraph renderParagraph = RenderParagraph(
        TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      softWrap: true,
    );

    renderParagraph.layout(constraints);

    double textLength = renderParagraph
        .getMinIntrinsicWidth(textStyle.fontSize)
        .ceilToDouble();

    double textHeight = renderParagraph
        .getMinIntrinsicHeight((MediaQuery
        .of(context)
        .size
        .width - (2 * AppDimensions.generalPadding)))
        .ceilToDouble();

    return textHeight;
  }

  static Future<String> getThumbnailFromVideoUrl(BuildContext context,
      String thumbnailPath) async {
    try {
      String thumbnailFilePath = await VideoThumbnail.thumbnailFile(
        video: thumbnailPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        quality: 70,
      ).catchError((error) {
        return AppConstants.VIDEO_THUMBNAIL_NULL_VALUE;
      });

      if (thumbnailFilePath?.isEmpty ?? true) {
        return AppConstants.VIDEO_THUMBNAIL_NULL_VALUE;
      }
      return thumbnailFilePath;
    } catch (e) {
      return AppConstants.VIDEO_THUMBNAIL_NULL_VALUE;
    }
  }

}

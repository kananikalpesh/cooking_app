import 'dart:math';

import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:flutter/material.dart';

const int FROM_GALLERY = 0;
const int FROM_CAMERA = 1;

typedef PickFileOptionCallBack(int option);

class PickFileOptionBottomSheet {
  static void showPickFileBottomSheet(
      context, PickFileOptionCallBack onPickFileOption) {
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(AppDimensions.generalBottomSheetRadius),
                topRight:
                    Radius.circular(AppDimensions.generalBottomSheetRadius),
              ),
              child: Container(
                  color: AppColors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          onPickFileOption(FROM_GALLERY);
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: AppDimensions.largeTopBottomPadding,
                              bottom: AppDimensions.generalTopPadding),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: Text(
                                    AppStrings.galleryOption,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .apply(
                                            fontSizeDelta: 2,
                                            color: AppColors.colorAccent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.generalTopPadding),
                      GestureDetector(
                        onTap: () {
                          onPickFileOption(FROM_CAMERA);
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: AppDimensions.generalTopPadding,
                                    bottom: AppDimensions.generalTopPadding),
                                child: Center(
                                    child: Text(
                                  AppStrings.cameraOption,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .apply(fontSizeDelta: 2, color: AppColors.colorAccent),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height:  max<double>(MediaQuery.of(context).padding.bottom, AppDimensions.padding_large)),
                    ],
                  )),
            ),
          );
        });
  }
}

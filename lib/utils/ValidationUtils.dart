
import 'dart:io';

import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';

class ValidationUtils {
  static Function getEmailAddressValidator(BuildContext context) {
    return (value) {
      if (value.isEmpty) {
        return AppStrings.emailEmpty;
      } else if (!RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
          .hasMatch(value as String)) {
        return AppStrings.emailInvalid;
      } else {
        return null;
      }
    };
  }

  static Function getPasswordValidator(BuildContext context, {String errorText}) {
    return (value) {
      if (value.isEmpty) {
        return (errorText != null) ? errorText : AppStrings.enterPassword;
      } else if (value.toString().length < 6) {
        return AppStrings.passwordMustBe;
      } else {
        return null;
      }
    };
  }

  static Function getPhoneValidator(BuildContext context) {
    return (value) {
      if (value.isEmpty) {
        return AppStrings.pleaseEnterMobile;
      } else if (value.toString().length < 5) {
        return AppStrings.mobileNumberValidation;
      } else {
        return null;
      }
    };
  }

  static Function getEmptyValidator(BuildContext context, String errorMessage) {
    return (value) {
      if (value.isEmpty) {
        return errorMessage;
      } else {
        return null;
      }
    };
  }

  static Function getEmptyValidatorAndCharLength(BuildContext context, String emptyErrorMessage,
      int charLength, String lengthErrorMessage) {
    return (value) {
      if (value.isEmpty) {
        return emptyErrorMessage;
      } else if (value.toString().length < charLength) {
        return lengthErrorMessage;
      } else {
        return null;
      }
    };
  }

  static Function getNullValidator(BuildContext context, String errorMessage) {
    return (value) {
      if (value == null) {
        return errorMessage;
      }  else {
        return null;
      }
    };
  }

  static Function getEmptyCodeValidator(BuildContext context) {
    return (value) {
      if (value.isEmpty) {
        return AppStrings.mobileCode;
      }  else {
        return null;
      }
    };
  }

  static Function getUrlValidator(BuildContext context) {
    return (value) {
      if (value.isEmpty) {
        return 'Url Empty';
      } else if (!RegExp(r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}'r'[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)')
          .hasMatch(value as String)) {
        return 'Invalid Url';
      } else {
        return null;
      }
    };
  }

  static Function fieldNext(BuildContext context, FocusNode node){
    return (value){ FocusScope.of(context).requestFocus(node); };
  }

  static bool fileNameValidator(context, String filePath){
    var lastIndex = filePath.lastIndexOf("/");
    String fileName = filePath
        .substring((lastIndex + 1), filePath.lastIndexOf("."))
        .replaceAllMapped(" ", (match) => "");
    if(!RegExp(r"^[A-Za-z0-9-_]*$").hasMatch(fileName)){
      CommonBottomSheet.invalidFileNameAlertBottomSheet(context);
      return false;
    }

    return true;
  }

  static Future<File> getFileFromNewFileName(File originalFile, {bool isImage = true, bool isDocument = false}) async {

    String preFixFileTypeName = (isDocument) ? "Doc" : (isImage ? "Image" : "Video");

    File newFile = originalFile;

    var lastIndex = newFile.path.lastIndexOf("/");
    var indexBeforeExtension = newFile.path.lastIndexOf(".");

    List<String> newPathList = newFile.path.characters.toList(); //
    newPathList.removeRange((lastIndex+1), indexBeforeExtension);
    newPathList.insertAll((lastIndex+1), "${preFixFileTypeName}_${DateTime.now().millisecondsSinceEpoch}".characters.toList());
    String newPath = "";
    newPathList.forEach((element) {
      newPath = "$newPath$element";
    });
    newFile = await newFile.rename(newPath);

    return newFile;
  }

}


import 'package:flutter/material.dart';

class ResultModel<T extends Object> {
  @required String error;
  @required T data;
  @required final int errorCode;
  @required final bool loading;
  ResultModel({this.error, this.data, this.errorCode, this.loading = false});

}

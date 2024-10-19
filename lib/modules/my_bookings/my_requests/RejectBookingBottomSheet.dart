
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RejectBookingBottomSheet{

   Future<dynamic> showRejectBookingSheet(BuildContext context, int lessonRequestId, MyRequestBloc myRequestBloc) async {
    var result = await showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: true,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.generalBottomSheetRadius),
                topRight: Radius.circular(AppDimensions.generalBottomSheetRadius),
              ),
              child: Container(
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, top: AppDimensions.generalPadding, bottom: AppDimensions.maxPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(AppStrings.rejectBookingRequest, style:Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, fontSizeDelta: 4,),),
                      SizedBox(height: AppDimensions.maxPadding,),
                      _BottomWidget(lessonRequestId, myRequestBloc),
                    ],
                  ),
                ),),
            ),
          );
        });
    return result;
  }
}

class _BottomWidget extends StatefulWidget {

  final int lessonRequestId;
  final MyRequestBloc myRequestBloc;

  _BottomWidget(this.lessonRequestId, this.myRequestBloc);

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<_BottomWidget> {

  ValueNotifier<String> _errorMessage = ValueNotifier("");
  final _formKey = GlobalKey<FormState>();
  var _reasonController = new TextEditingController();
  FocusNode _focusReason;
  String _reason;

  @override
  void initState() {

    widget.myRequestBloc.obsRejectRequest.stream.listen((result) {
      if (result.error != null) {
        _errorMessage.value = result.error;
      } else {
        Navigator.of(context).pop(true);
      }
    });

    _focusReason = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                    labelText: AppStrings.note),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                autofocus: false,
                focusNode: _focusReason,
                onSaved: (value) => _reason = value,
                validator: ValidationUtils.getEmptyValidator(context, AppStrings.reasonError),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ValueListenableProvider<String>.value(
                value: _errorMessage,
                child: Consumer<String>(
                  builder: (context, value, child) {
                    return Offstage(
                      offstage: ((value?.isEmpty ?? true)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimensions.generalPadding,
                          right: AppDimensions.generalPadding,
                          top: AppDimensions.generalPadding,
                        ),
                        child: Text(
                          "$value",
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.errorTextColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: AppDimensions.generalPadding,
            ),
            ValueListenableProvider<bool>.value(
              value: widget.myRequestBloc.isRejectRequestLoading,
              child: Consumer<bool>(
                builder: (context, loading, child) {
                  return (loading) ? _getLoaderWidget() : _getSubmitButton();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  Widget _getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();

                  Map<String, dynamic> data = <String, dynamic>{
                    "lr": widget.lessonRequestId,
                    "n": _reason,
                  };
                  widget.myRequestBloc.event.add(EventModel(MyRequestBloc.REJECT_BOOKING_REQUEST, data: data));
                }
              },
              child: Text(AppStrings.rejectButtonName),
            ),
          ),
        ],
      ),
    );
  }

}
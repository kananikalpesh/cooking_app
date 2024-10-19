
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/video_chat/ReviewBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewBottomSheet{

  static void reviewSheet(
      BuildContext context, int cookId, int lessonId, int lessonBookingId, int userId, {bool isOpenedFromCookSide = false}) {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 26),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft:
                  Radius.circular(AppDimensions.generalBottomSheetRadius),
                  topRight:
                  Radius.circular(AppDimensions.generalBottomSheetRadius),
                ),
                child: Container(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: AppDimensions.generalPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppStrings.reviewLabel,
                          style: Theme.of(context).textTheme.subtitle1.apply(
                            fontWeightDelta: -1,
                            fontSizeDelta: 4,
                          ),
                        ),
                        SizedBox(
                          height: AppDimensions.largeTopBottomPadding,
                        ),
                        ReviewDialogWidget(cookId, lessonId, lessonBookingId, userId, isOpenedFromCookSide),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

}

class ReviewDialogWidget extends StatefulWidget{

  final int lessonId;
  final cookId;
  final int lessonBookingId;
  final int userId;
  final bool isOpenedFromCookSide;

  ReviewDialogWidget(this.cookId, this.lessonId, this.lessonBookingId, this.userId, this.isOpenedFromCookSide);

  @override
  State<StatefulWidget> createState() => ReviewDialogWidgetState();
}

class ReviewDialogWidgetState extends State<ReviewDialogWidget>{

  String _cookReview;
  String _lessonReview;
  FocusNode _focusCookReview;
  FocusNode _focusLessonReview;
  final _formKey = GlobalKey<FormState>();
  var _editCookReview = new TextEditingController();
  var _editLessonReview = new TextEditingController();
  double cookRating = 1.0;
  double lessonRating = 1.0;
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<String> _apiResponseError = ValueNotifier("");
  ReviewBloc _bloc;

  @override
  void initState() {
    _bloc  = ReviewBloc();
    _focusCookReview = FocusNode();
    _focusLessonReview = FocusNode();
    _bloc.obsAddReview.listen((resultModel) {

      if(resultModel.error != null){
        isLoading.value = false;
        _apiResponseError.value = resultModel.error;
      }else{
        Navigator.pop(context);
      }

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Text((widget.isOpenedFromCookSide) ? AppStrings.reviewUserLabel : AppStrings.reviewCookLabel),
              ],
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalTopPadding),
                  child: RatingBar.builder(
                    initialRating: 1,
                    minRating: 1,
                    direction: Axis.horizontal,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: AppColors.starRating,
                    ),
                    itemCount: 5,
                    itemSize: 40.0,
                    unratedColor: AppColors.nonSelectedStarRating,
                    onRatingUpdate: (rating) {
                      this.cookRating= rating;
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.only(
                top: AppDimensions.generalPadding,
              ),
              child: TextFormField(
                controller: _editCookReview,
                decoration:
                InputDecoration(hintText: AppStrings.hintReviewComment),
                maxLines: 5,
                minLines: 3,
                autofocus: false,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                focusNode: _focusCookReview,
                onSaved: (value) {
                  _cookReview = value;
                },
                validator: ValidationUtils.getEmptyValidator(
                    context, AppStrings.enterReviewComment),
              ),
            ),
            SizedBox(height: AppDimensions.generalPadding,),

            (widget.isOpenedFromCookSide) ? Container() : _getLessonReviewWidget(),


            ValueListenableProvider<String>.value(
              value: _apiResponseError,
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
            SizedBox(
              height: AppDimensions.largeTopBottomPadding,
            ),
            ValueListenableProvider<bool>.value(
              value: isLoading,
              child: Consumer<bool>(
                builder: (context, loading, child) {
                  return (loading) ? _getLoaderWidget() : getSubmitButton();
                },
              ),
            ),
          ],),
      ),
    );
  }

  Widget _getLessonReviewWidget(){
    return Column(children: [
      Row(
        children: [
          Text(AppStrings.reviewLessonLabel),
        ],
      ),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalTopPadding),
            child: RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: AppColors.starRating,
              ),
              itemCount: 5,
              itemSize: 40.0,
              unratedColor: AppColors.nonSelectedStarRating,
              onRatingUpdate: (rating) {
                this.lessonRating = rating;
              },
            ),
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(
          top: AppDimensions.generalPadding,
        ),
        child: TextFormField(
          controller: _editLessonReview,
          decoration:
          InputDecoration(hintText: AppStrings.hintReviewComment),
          maxLines: 5,
          minLines: 3,
          autofocus: false,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          focusNode: _focusLessonReview,
          onSaved: (value) {
            _lessonReview = value;
          },
          validator: ValidationUtils.getEmptyValidator(
              context, AppStrings.enterReviewComment),
        ),
      ),
      SizedBox(height: AppDimensions.generalPadding,),
    ],);
  }

  @override
  void dispose() {
    _focusCookReview.dispose();
    _focusLessonReview.dispose();
    super.dispose();
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator()
        ],
      ),
    );
  }

  Widget getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.generalPadding,
      ),
      child: ElevatedButton(
        onPressed: () {
          _processForm();
        },
        child: Text(AppStrings.submitLabel),
      ),
    );
  }

  _processForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _apiResponseError.value = "";

      isLoading.value = true;

      Map<String, dynamic> data;

      if(AppData.user.role == AppConstants.ROLE_COOK){
        data = <String, dynamic>{
          "k": widget.userId,
          "r": cookRating.toInt(),
          "c": _cookReview,
          "lb" : widget.lessonBookingId
        };
      }else{
        Map<String, dynamic> cookReview = <String, dynamic>{
          "k": widget.cookId,
          "r": cookRating.toInt(),
          "c": _cookReview
        };

        Map<String, dynamic> lessonReview = <String, dynamic>{
          "l": widget.lessonId,
          "r": lessonRating.toInt(),
          "c": _lessonReview,
          "b" : widget.lessonBookingId
        };

        data = <String, dynamic>{
          "cook": cookReview,
          "lesson": lessonReview,
        };
      }

      _bloc.event.add(EventModel(ReviewBloc.SEND_REVIEW, data: data));
    }
  }

}
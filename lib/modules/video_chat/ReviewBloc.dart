
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/video_chat/ReviewRepository.dart';
import 'package:rxdart/rxdart.dart';

class ReviewBloc extends Bloc{
  static const String TAG = "ReviewBloc";

  static const String SEND_REVIEW = "send_review";

  var _repository = ReviewRepository();

  final event = PublishSubject<EventModel>();

  final obsAddReview = PublishSubject<ResultModel>();

  ReviewBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case SEND_REVIEW:
          _handleAddReview(event.data);
          break;
      }
    });
  }

  _handleAddReview(Map<String, dynamic> data) async {
    ResultModel result = await  _repository.addReview(data);
    obsAddReview.add(result);
  }

  @override
  void dispose() {
    event.close();
    obsAddReview.close();
  }
}
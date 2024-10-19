
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/admin/payments/AllPaymentsBloc.dart';
import 'package:cooking_app/modules/admin/payments/PaymentItemWidget.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class AllPaymentsScreen extends StatefulWidget {

  @override
  _AllPaymentsScreenState createState() => _AllPaymentsScreenState();
}

class _AllPaymentsScreenState extends State<AllPaymentsScreen> {

  AllPaymentsBloc _bloc;

  StreamSubscription _paymentListSubscription;
  ScrollController _listScrollController;

  @override
  void initState() {
    _bloc = AllPaymentsBloc();

    _listScrollController = ScrollController();
    _listScrollController.addListener(() {
      if (_listScrollController.offset >=
          _listScrollController.position.maxScrollExtent &&
          !_listScrollController.position.outOfRange) {
        if (!_bloc.loadingNextPageData.value) {
          if (_bloc.listSizeOfCurrentFetch >= _bloc.getPageSize) {
            _bloc.loadingNextPageData.value = true;
            _loadNewData();
          }
        }
      }
    });

    _paymentListSubscription = _bloc.obsGetPaymentLists.stream.listen((result) {
      _bloc.setCount = (_bloc.paymentsList.length);
      if (result?.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      }
    });

    _loadNewData();

    super.initState();
  }

  @override
  void dispose() {
    if (_paymentListSubscription != null) {
      _paymentListSubscription.cancel();
      _bloc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: mainContainerWidget(), controller: _listScrollController,);
  }

  Widget _getEmptyListWidget() {
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: Text(AppStrings.emptyPaymentData,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getInitialLoaderWidget() {
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget mainContainerWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding,
            top: AppDimensions.generalPadding, bottom: AppDimensions.maxPadding,),
          child: Text(AppStrings.payments, style: Theme.of(context).textTheme.headline5),
        ),
        ValueListenableProvider<bool>.value(
          value: _bloc.isLoadingFirstPage,
          child: Consumer<bool>(
            builder: (context, isLoadingFirstPage, child) {
              return ValueListenableProvider<int>.value(
                value: _bloc.getCount,
                child: Consumer<int>(
                  builder: (context, valueListCount, child) {
                    return (isLoadingFirstPage)
                        ?  _getInitialLoaderWidget()
                        : (valueListCount == 0)
                        ? _getEmptyListWidget()
                        : _getPaymentListBuilder(valueListCount);
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppDimensions.maxPadding,),
      ],
    );
  }

  _loadNewData() {
    _bloc.obsGetPaymentLists.sink.add(null);
    _bloc.event.add(EventModel(AllPaymentsBloc.GET_PAYMENTS));
  }

  Widget _getPaymentListBuilder(int valueListCount) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: valueListCount + 1,
        padding: EdgeInsets.only(left: AppDimensions.generalPadding,
            right: AppDimensions.generalPadding),
        itemBuilder: (context, index) {
          if (index == (valueListCount)) {
            return ValueListenableProvider<bool>.value(
              value: _bloc.loadingNextPageData,
              child: Consumer<bool>(
                builder: (context, value, child) {
                  Future.delayed(
                      Duration(
                        milliseconds: 10,
                      ), () {
                    if (value && (index == (valueListCount))) {
                      _listScrollController.jumpTo(
                          _listScrollController.position.maxScrollExtent);
                    }
                  });
                  return Offstage(
                    offstage: (!value),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,
                          bottom: AppDimensions.generalPadding),
                      child: Center(
                        child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return PaymentItemWidget(_bloc.paymentsList[index]);
          }
        });
  }

}

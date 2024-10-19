
import 'package:cooking_app/modules/admin/payments/PaymentListModel.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';

class PaymentItemWidget extends StatefulWidget {
  final AdminPaymentDetailsModel paymentModel;
  PaymentItemWidget(this.paymentModel);

  @override
  State<StatefulWidget> createState() => PaymentItemWidgetState();
}

class PaymentItemWidgetState extends State<PaymentItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(margin: EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(AppStrings.transDate,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text((widget.paymentModel?.date != null) ? "${widget.paymentModel.date}" : "-",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              )
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(AppStrings.paymentAmount,
                    style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text((widget.paymentModel?.bookingAmount != null) ? "${AppStrings.dollar}${widget.paymentModel.bookingAmount}" : "-",
                    style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(AppStrings.transAmount,
                    style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text((widget.paymentModel?.transactionFee != null) ? "${AppStrings.dollar}${widget.paymentModel.transactionFee.toStringAsFixed(2)}" : "-",
                    style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    ),);
  }
}

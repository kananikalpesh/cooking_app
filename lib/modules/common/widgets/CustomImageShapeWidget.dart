
import 'package:cooking_app/utils/AppColors.dart';
import 'package:flutter/cupertino.dart';

class CustomImageShapeWidget extends StatelessWidget{

  CustomImageShapeWidget(this.width, this.height, this.radius, this.image, {this.borderColor = AppColors.backgroundGrey300});

  final double radius;
  final Color borderColor;
  final Widget image;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        //shape: BoxShape.circle,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: image,),);
  }
}
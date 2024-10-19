
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:flutter/material.dart';

class CustomSliverOverlapAbsorber extends StatefulWidget {

  final BuildContext parentContext;
  final double expandedHeight;
  final String title;
  final String imagePath;
  final List<Widget> actions;

  CustomSliverOverlapAbsorber({this.parentContext, @required this.expandedHeight,
    @required this.title, @required this.imagePath, this.actions});

  @override
  _CustomSliverOverlapAbsorberState createState() => _CustomSliverOverlapAbsorberState();
}

class _CustomSliverOverlapAbsorberState extends State<CustomSliverOverlapAbsorber> {
  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor((widget.parentContext != null ? widget.parentContext : context)),
      sliver: SliverSafeArea(top: false,
          sliver: SliverAppBar(
              //title: widget.title,
              actions: (widget.actions == null) ? [] : widget.actions,
              pinned: true,
              floating: false,
              snap: false,
              elevation: 0,
              expandedHeight: widget.expandedHeight,
              backgroundColor: AppColors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.title, style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black, fontFamily: 'Custom', fontWeight: FontWeight.w600),),
                collapseMode: CollapseMode.parallax,
                background: CachedNetworkImage(
                  key: GlobalKey(),
                  fit: BoxFit.fill,
                  imageUrl: widget.imagePath,
                  progressIndicatorBuilder: (context,
                      url, downloadProgress) =>
                      Image.asset(
                        "assets/loading_image.png",
                        fit: BoxFit.contain,
                      ),
                  errorWidget:
                      (context, url, error) =>
                      Image.asset(
                        "assets/error_image.png",
                        fit: BoxFit.contain,
                      ),
                ),
              ),
          ),
      ),
    );
  }
}

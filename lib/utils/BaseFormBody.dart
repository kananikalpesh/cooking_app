import 'package:flutter/widgets.dart';

class BaseFormBody extends StatefulWidget {
  final Widget child;

  BaseFormBody({this.child});

  @override
  State<StatefulWidget> createState() => BaseFormBodyState();
}

class BaseFormBodyState extends State<BaseFormBody> {
  BaseFormBodyState();

  FocusNode _focusGen;

  @override
  void initState() {
    super.initState();
    _focusGen = FocusNode();
  }

  @override
  void dispose() {
    _focusGen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(_focusGen);
      },
      child: widget.child,
    ));
  }
}

import 'package:flutter/widgets.dart';

class BaseFormBodyUnsafe extends StatefulWidget {
  final Widget child;

  BaseFormBodyUnsafe({this.child});

  @override
  State<StatefulWidget> createState() => _BaseFormBodyState();
}

class _BaseFormBodyState extends State<BaseFormBodyUnsafe> {

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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(_focusGen);
      },
      child: widget.child,
    );
  }
}

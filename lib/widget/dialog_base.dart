import 'package:flutter/material.dart';
import 'package:tds_android_util/utils/ui_utils.dart';

class DialogBase extends StatelessWidget {

  final Widget child;
  final AlignmentGeometry? align;

  const DialogBase({super.key,required this.child,this.align});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.dialogWidth,
        height: context.dialogHeight,
        alignment: align ?? Alignment.center,
        color: Colors.white,
        child: child
    );
  }
}
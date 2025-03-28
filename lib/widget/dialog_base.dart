import 'package:flutter/material.dart';
import 'package:tds_android_util/utils/ui_utils.dart';

class DialogBase extends StatelessWidget {

  final Widget child;
  final AlignmentGeometry? align;
  final double? width;
  final double? height;

  const DialogBase({super.key,required this.child,this.align,this.width,this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? context.dialogWidth,
        height: height ?? context.dialogHeight,
        alignment: align ?? Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)
        ),
        child: child
    );
  }
}
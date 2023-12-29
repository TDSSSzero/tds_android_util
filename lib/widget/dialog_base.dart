import 'package:flutter/material.dart';

class DialogBase extends StatelessWidget {

  final Widget child;
  final AlignmentGeometry? align;

  const DialogBase({super.key,required this.child,this.align});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 600,
        height: 600,
        alignment: align ?? Alignment.center,
        color: Colors.white,
        child: child
    );
  }
}
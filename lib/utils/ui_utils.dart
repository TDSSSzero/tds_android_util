import 'package:flutter/cupertino.dart';

/// author TDSSS
/// datetime 2024/7/8
final class UIUtils {
  UIUtils._();

}

extension BuildContextEx on BuildContext{
   double get dialogWidth => MediaQuery.sizeOf(this).width * 0.8;
   double get dialogHeight => MediaQuery.sizeOf(this).height * 0.8;
}
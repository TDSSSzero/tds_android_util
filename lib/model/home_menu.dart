import 'package:tds_android_util/function.dart';

/// author TDSSS
/// datetime 2025/2/8
class HomeMenu {
  String name;
  Function() func;
  SingleCallback? singleCallback;
  List<MenuTag>? tagList;

  HomeMenu(this.name,this.func,{this.tagList,this.singleCallback});

}

enum MenuTag{
  wifiDisable,
  needDevice,
  heroPage,
}
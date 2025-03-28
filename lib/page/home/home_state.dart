import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tds_android_util/manager/sp_manager.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'package:tds_android_util/model/sign_info.dart';

import '../../model/android_device.dart';
import '../../model/home_menu.dart';

class HomeState {
  final currentResult = CommandResult.init().obs;
  final results = <CommandResult>[].obs;
  final devices = <AndroidDevice>[].obs;
  final currentDevice = AndroidDevice.init().obs;
  RxInt selectedIndex = (-1).obs;

  final signInfoList = <SignInfo>[].obs;
  late final SharedPreferences sp;

  List<HomeMenu> menu = [];

  List<HomeMenu> get needDeviceMenu => menu.where((element) => element.tagList?.contains(MenuTag.needDevice) ?? false).toList();
  List<HomeMenu> get normalMenu => menu.where((element) => (element.tagList == null) || (!element.tagList!.contains(MenuTag.needDevice)) ).toList();

  HomeState() {
    initSp();
  }

  void initSp()async{
    await SpManager().init();
    sp = SpManager().sp;
  }

}

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'package:tds_android_util/model/sign_info.dart';

import '../../model/android_device.dart';

class HomeState {
  final currentResult = CommandResult.init().obs;
  final results = <CommandResult>[].obs;
  final devices = <AndroidDevice>[].obs;
  final currentDevice = AndroidDevice.init().obs;
  RxInt selectedIndex = (-1).obs;

  final signInfoList = <SignInfo>[].obs;
  late final SharedPreferences sp;
  HomeState() {
    initSp();
  }

  void initSp()async{
    sp = await SharedPreferences.getInstance();
  }

}

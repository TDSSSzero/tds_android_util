import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tds_android_util/model/app_info.dart';

import '../../manager/sp_manager.dart';

class ClearAppState {

  late final SharedPreferences sp;
  final appList = <AppInfo>[].obs;
  final currentApp = AppInfo("", "").obs;

  ClearAppState() {
    sp = SpManager().sp;
  }

}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/common/command_util.dart';
import 'package:tds_android_util/common/sp_key.dart';
import 'package:tds_android_util/model/app_info.dart';
import 'package:tds_android_util/page/home/home_logic.dart';

import 'clear_app_state.dart';

class ClearAppLogic extends GetxController {
  final ClearAppState state = ClearAppState();

  final packageCtrl = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    _loadApps();
  }

  onSelectAppInfo(int? index){
    if(index == null)return;
    state.currentApp.value = state.appList[index];
    state.currentApp.refresh();
    print("select app : ${state.currentApp.value.package}");
  }

  onCustomPackageInput(String s){

  }

  onClear() {
    _clear(state.currentApp.value.package);
  }

  onClearCustom() {
    _clear(packageCtrl.text);
  }

  _clear(String package) async{
    if(package.isEmpty){
      _showToast(1);
      return;
    }

    final homeLogic = Get.find<HomeLogic>();
    final res = await CommandUtils.clearAppData(package, homeLogic.state.currentDevice.value.name);
    _showToast(res.isSuccess ? 2 : 3);

  }

  _showToast(int index){
    String msg = "";
    switch(index){
      case 1:
        msg = "未选择app info或者包名为空";
        break;
      case 2:
        msg = "清除成功！";
        break;
      case 3:
        msg = "清除失败！";
        break;
    }
    if(msg.isEmpty)return;
    SmartDialog.showToast(msg);
  }

  _loadApps(){
    final stringList = state.sp.getStringList(SPKey.stringPackages);
    if(stringList == null){
      _initApps();
      return;
    }
    for(var strData in stringList){
      state.appList.add(AppInfo.fromJson(jsonDecode(strData)));
    }
  }

  _initApps(){
    state.appList.addAll([
      AppInfo("数学(Arcadia Zen Math)", "com.arcadiastudio.zen.math.puzzle.free",launchActivity: "MainActivity"),
      AppInfo("新连连看(Arcadia Onet Match)", "com.arcadiastudio.onet.match.puzzle",launchActivity: "MainActivity"),
    ]);
    state.sp.setStringList(SPKey.stringPackages, state.appList.map((e) => jsonEncode(e.toJson())).toList());
  }

}

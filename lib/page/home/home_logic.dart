import 'dart:convert';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/model/android_device.dart';
import 'package:tds_android_util/page/home/dialog/add_sign_info_dialog.dart';
import 'package:tds_android_util/page/home/dialog/build_aab_dialog.dart';
import 'package:tds_android_util/page/home/dialog/copy_file_dialog.dart';
import 'package:tds_android_util/page/home/dialog/qr_dialog.dart';
import 'package:tds_android_util/page/home/drop_file_dialog.dart';
import 'package:tds_android_util/page/home/text_field_dialog.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

import '../../common/command_util.dart';
import '../../common/regex_util.dart';
import '../../common/sp_key.dart';
import '../../model/command_result.dart';
import '../../model/sign_info.dart';
import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  bool get isHaveSelectedDevice {
    for(var d in state.devices){
      if(d.isSelected) return true;
    }
    return false;
  }

  @override
  void onReady() {
    _loadSignInfo();
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  List<String> get menuString => ["获取设备列表","手动无线连接","无线连接设备","复制文件到手机","安装apk","安装aab","预设签名信息","test"];
  Future<CommandResult?> menuLogic(int index)async {
    CommandResult? res;
    switch (index) {
      case 0 :
        res = await _getDevicesInfo();
      case 1:
        String connectIp = "";
        await SmartDialog.show(builder: (_)=> TextFieldDialog(onTextChanged: (ip)async{
          connectIp = ip;
        }));
        res = await CommandUtils.runCommand(getAdbPath(), ["connect",connectIp]);
      case 2:
        if(state.currentDevice.value.isUnknown) return null;
        if(state.currentDevice.value.ip == null){
          SmartDialog.showToast("ip未知");
          return null;
        }
        res = await CommandUtils.runCommand(getAdbPath(), ["connect",state.currentDevice.value.ip!]);
        if(res.outString.contains("cannot connect")){
          print("cannot connect");
          SmartDialog.showToast("默认连接失败，尝试启动adbd重连");
          res = await CommandUtils.runAdbOfDevice(["tcpip","5555"],state.currentDevice.value.name);
          print(res);
          res = await CommandUtils.runCommand(getAdbPath(), ["connect",state.currentDevice.value.ip!]);
          if(res.exitCode == 0) SmartDialog.showToast("连接成功！");
          res = await _getDevicesInfo();
        }
      case 3:
        SmartDialog.show(builder: (_) => CopyFileDialog(deviceName: state.currentDevice.value.name));
      case 4:
        SmartDialog.show(builder: (_)=>
            DropFileDialog(onSave: (isCopy,path)async{
              print("isCopy : $isCopy,path : $path");
              SmartDialog.dismiss(status: SmartStatus.dialog);
              SmartDialog.showLoading(msg: "安装中...");
              state.currentResult.value = await CommandUtils.runAdbOfDevice(["install",path], state.currentDevice.value.name);
              state.currentResult.refresh();
              SmartDialog.dismiss(status: SmartStatus.loading);
              },
              onInstallOpen: (isCopy,path)async{
                print("isCopy : $isCopy,path : $path");
                SmartDialog.dismiss(status: SmartStatus.dialog);
                SmartDialog.showLoading(msg: "安装中...");
                final res = await CommandUtils.runAdbOfDevice(["install",path], state.currentDevice.value.name);
                SmartDialog.dismiss(status: SmartStatus.loading);
                if(res.outString.contains("Success")){
                  print("install success");
                  var apkInfo = await CommandUtils.getApkInfo(path);
                  print("apkInfo $apkInfo");
                  state.currentResult.value = await CommandUtils.launchApplication(state.currentDevice.value.name, apkInfo.packageName!,launchActivityName: apkInfo.launchActivity);
                }else{
                  state.currentResult.value = CommandResult(exitCode: 1, outString: "",errorString: "出错",command: "aapt dump badging $path");
                }
                state.currentResult.refresh();
                SmartDialog.dismiss(status: SmartStatus.loading);
              },
            )
        );
      case 5:
        res = await SmartDialog.show(builder: (_)=>BuildAabDialog(device: state.currentDevice.value,signInfoList: state.signInfoList,));
      case 6:
        res = await SmartDialog.show(builder: (_)=>AddSignInfoDialog());
        _loadSignInfo();
      case 7:
        // res = await CommandUtils.runCommand(getAdbPath(), ["shell","getprop"]);
        // SmartDialog.show(builder: (context) => QrDialog());
    }
    if(res != null) {
      state.currentResult.value = res;
      state.currentResult.refresh();
    }
    return res;
  }

  Future<CommandResult?> _getDevicesInfo()async{
    CommandResult? res;
    res = CommandUtils.getDevices();
    _resolveDevices(res);
    _resolveIp();
    // print("isUnknown : ${state.currentDevice.value.isUnknown}");
    for (var i = 0; i < state.devices.length; ++i) {
      var device = state.devices[i];
      var res = await CommandUtils.runAdbOfDevice(CommandUtils.getDeviceModel, device.name);
      var marketName = await CommandUtils.runAdbOfDevice(CommandUtils.getDeviceMarketName, device.name);
      state.devices[i].model = res.outString;
      state.devices[i].marketName = marketName.outString;
    }
    print("devices : ${state.devices}");
    if(state.devices.isNotEmpty) state.devices.refresh();
    state.currentDevice.value = AndroidDevice.init();
    state.selectedIndex.value = -1;
    return res;
  }

  void _resolveDevices(CommandResult res){
    state.devices.clear();
    String resString = res.outString;
    RegExp regex = RegExp(r"(\w+)\sdevice\s|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+)\sdevice");
    var match = regex.allMatches(resString);

    for (var res in match) {
      if (res.group(1) != null) {
        // print("Serial number 1: ${res.group(1)}");
        state.devices.add(AndroidDevice(res.group(1)!));
      }
      if (res.group(2) != null) {
        // print("ip 2: ${res.group(2)}");
        state.devices.add(AndroidDevice(res.group(2)!,isWifiConnected: true));
      }
    }
  }

  void _resolveIp(){
    if(state.devices.isEmpty)return;
    for (int i = 0; i < state.devices.length; i++) {
      if(state.devices[i].isWifiConnected) continue;
      final ipRes = CommandUtils.getDeviceIp(deviceName: state.devices[i].name);
      state.devices[i].ip = RegexUtil.matchAdbIp(ipRes.outString);
      final list = RegexUtil.matchIp(state.devices[i].name);
      if(list.isEmpty) continue;
      String nameIp = RegexUtil.matchIp(state.devices[i].name)[0];
      state.devices[i].isWifiConnected = nameIp == state.devices[i].ip;
    }
    // if(state.devices.length == 1 && !state.devices[0].isWifiConnected){
    //   final ipRes = CommandUtils.getDeviceIp();
    //   print("ip ipRes : $ipRes");
    //   state.devices[0].ip = RegexUtil.matchAdbIp(ipRes.outString);
    //
    //   final list = RegexUtil.matchIp(state.devices[0].name);
    //   print("ip list : $list");
    //   if(list.isEmpty) return;
    //
    //   String nameIp = RegexUtil.matchIp(state.currentDevice.value.name)[0];
    //   state.currentDevice.value.isWifiConnected = nameIp == state.currentDevice.value.ip;
    // }else{
    //   for (int i = 0; i < state.devices.length; i++) {
    //     if(state.devices[i].isWifiConnected) continue;
    //     final ipRes = CommandUtils.getDeviceIp(deviceName: state.devices[i].name);
    //     state.devices[i].ip = RegexUtil.matchAdbIp(ipRes.outString);
    //     final list = RegexUtil.matchIp(state.devices[i].name);
    //     if(list.isEmpty) continue;
    //     String nameIp = RegexUtil.matchIp(state.devices[i].name)[0];
    //     state.devices[i].isWifiConnected = nameIp == state.devices[i].ip;
    //   }
    // }
  }


  void _loadSignInfo()async{
    state.signInfoList.clear();
    final strList = state.sp.getStringList(SPKey.stringSignInfo);
    print("length : ${strList?.length}");
    if(strList == null) return;
    for (var i = 0; i < strList.length; ++i) {
      state.signInfoList.add(SignInfo.fromJson(jsonDecode(strList[i])));
    }
    print("sign list: ${state.signInfoList}");
  }
}

import 'dart:convert';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/model/android_device.dart';
import 'package:tds_android_util/page/home/dialog/add_sign_info_dialog.dart';
import 'package:tds_android_util/page/home/dialog/build_aab_dialog.dart';
import 'package:tds_android_util/page/home/dialog/copy_file_dialog.dart';
import 'package:tds_android_util/page/home/drop_file_dialog.dart';
import 'package:tds_android_util/page/home/text_field_dialog.dart';

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

  List<String> get menuString => [
    "获取设备列表", "主动ip无线连接\n（需连接过一次）", "无线连接设备",
    "复制文件到手机","安装apk","安装aab",
    "预设签名信息","自定义命令"
    // ,"test"
  ];
  menuLogic(int index)async {
    CommandResult res;
    switch (index) {
      case 0 : //获取设备列表
        res = await _getDevicesInfo();
        state.currentResult.value = res;
        state.results.add(res);
      case 1: //手动无线连接
        res = await _ipConnect();
        if(res.exitCode != CommandResultCode.defaultCode){
          state.results.add(res);
          if(res.isSuccess && !res.outString.contains("empty")) SmartDialog.showToast("连接成功！");
          await Future.delayed(const Duration(seconds: 1));
          _getDevicesInfo();
        }
      case 2: //无线连接设备
        res = await _wifiConnect();
        if(res.isSuccess) SmartDialog.showToast("连接成功！");
        await Future.delayed(const Duration(seconds: 1));
        _getDevicesInfo();
      case 3: //复制文件到手机
        SmartDialog.show(builder: (_) => CopyFileDialog(deviceName: state.currentDevice.value.name));
      case 4: //安装apk
        _installApk();
      case 5: //安装aab
        CommandResult? tempRes = await SmartDialog.show(builder: (_)=>BuildAabDialog(device: state.currentDevice.value,signInfoList: state.signInfoList));
        if(tempRes != null){
          state.currentResult.value = tempRes;
          state.results.add(tempRes);
        }
      case 6: //预设签名信息
        await SmartDialog.show(builder: (_)=>const AddSignInfoDialog());
        _loadSignInfo();
      case 7: //自定义命令
        String cmdStr = "";
        await SmartDialog.show(builder: (_)=> TextFieldDialog(
          onTextChanged: (s) => cmdStr = s,
          defaultStr: cmdStr,
        ));
        if(cmdStr == "") return CommandResult(exitCode: CommandResultCode.error, outString: "未知命令", command: cmdStr);
        var command = cmdStr.split(' ');
        res = await CommandUtils.runCommand(getAdbPath(), command);
      // case 8://test
      //   // var apkInfo = await CommandUtils.getApkInfo(r"D:\note\AracdiaOnetNote\Android提包\0813\apks\aa.apk");
      //   var asd = await CommandUtils.getApkInfo(r"D:\note\AracdiaOnetNote\Android提包\Arcadia Onet Match_1.2.4(22)_release.apk");
      //   // print("apkInfo $apkInfo");
      //   print("asd $asd");
    }
  }

  Future<CommandResult> _getDevicesInfo()async{
    CommandResult res;
    res = CommandUtils.getDevices();
    if(!res.isSuccess) return CommandResult(exitCode: CommandResultCode.error, outString: "查找设备命令出错", command: "adb devices");
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

    //如果有设备，默认选中第一条
    if(state.devices.isNotEmpty){
      state.selectedIndex.value = 0;
      state.currentDevice.value = state.devices[0];
    }

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

  ///解析设备IP
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

  Future<CommandResult> _ipConnect()async{
    String connectIp = "";
    String lastIp = state.sp.getString(SPKey.stringIp) ?? "192.168.";
    await SmartDialog.show(
        builder: (_)=> TextFieldDialog(
        onTextChanged: (ip)async{
      connectIp = ip;
    },
      defaultStr: lastIp,
    ));
    if(connectIp == "") return CommandResult.init();
    state.sp.setString(SPKey.stringIp, connectIp);
    return CommandUtils.runCommand(getAdbPath(), ["connect",connectIp]);
  }

  Future<CommandResult> _wifiConnect()async{
    CommandResult res;
    if(state.currentDevice.value.isUnknown) return CommandResult(exitCode: CommandResultCode.error, outString: "未获取到连接状态", command: '');
    if(state.currentDevice.value.ip == null){
      SmartDialog.showToast("ip未知");
      return CommandResult(exitCode: CommandResultCode.error, outString: "ip未知", command: '');
    }
    res = await CommandUtils.runCommand(getAdbPath(), ["connect",state.currentDevice.value.ip!]);
    state.results.add(res);
    if(res.outString.contains("cannot connect")){
      print("cannot connect");
      SmartDialog.showToast("默认连接失败，尝试启动adbd重连");
      res = await CommandUtils.runAdbOfDevice(["tcpip","5555"],state.currentDevice.value.name);
      state.results.add(res);
      print(res);
      res = await CommandUtils.runCommand(getAdbPath(), ["connect",state.currentDevice.value.ip!]);
      state.results.add(res);
      return res;
    }
    return CommandResult(exitCode: CommandResultCode.error, outString: "未知错误", command: '');
  }

  void _installApk()async{
    CommandResult res;
    SmartDialog.show(builder: (_)=>
        DropFileDialog(onSave: (isCopy,path)async{
          print("isCopy : $isCopy,path : $path");
          SmartDialog.showLoading(msg: "安装中...");
          res = await CommandUtils.runAdbOfDevice(["install",path], state.currentDevice.value.name);
          state.currentResult.value = res;
          state.results.add(res);
          state.currentResult.refresh();
          SmartDialog.dismiss(status: SmartStatus.loading);
          SmartDialog.dismiss(status: SmartStatus.dialog);
          if(!state.currentResult.value.isSuccess){
            SmartDialog.showToast("安装失败");
          }
        },
          onInstallOpen: (isCopy,path)async{
            print("isCopy : $isCopy,path : $path");
            SmartDialog.dismiss(status: SmartStatus.dialog);
            SmartDialog.showLoading(msg: "安装中...");
            res = await CommandUtils.runAdbOfDevice(["install",path], state.currentDevice.value.name);
            state.results.add(res);
            SmartDialog.dismiss(status: SmartStatus.loading);
            if(res.outString.contains("Success")){
              print("install success");
              var apkInfo = await CommandUtils.getApkInfo(path);
              if(apkInfo == null){
                res = CommandResult(exitCode: CommandResultCode.error, outString: "",errorString: "出错",command: "aapt dump badging $path");
              }else{
                print("apkInfo $apkInfo");
                res = await CommandUtils.launchApplication(state.currentDevice.value.name, apkInfo.packageName!,launchActivityName: apkInfo.launchActivity);
              }
              state.currentResult.value = res;
              state.results.add(res);
            }
            state.currentResult.refresh();
            SmartDialog.dismiss(status: SmartStatus.loading);
          },
        )
    );
  }

}

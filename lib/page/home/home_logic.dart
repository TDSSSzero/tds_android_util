import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/model/android_device.dart';
import 'package:tds_android_util/model/home_menu.dart';
import 'package:tds_android_util/page/clear_app/clear_app_view.dart';
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
    for (var d in state.devices) {
      if (d.isSelected) return true;
    }
    return false;
  }

  @override
  void onInit() {
    _initMenu();
    super.onInit();
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

  void onChangeSelectDevice(int? v) {
    state.selectedIndex.value = v ?? -1;
    if (v == null) return;
    state.currentDevice.value = state.devices[v];
    print("current device : ${state.currentDevice.value}");
  }

  void _initMenu() {
    state.menu = [
      _createGetDevicesMenu(),
      _createIpConnectMenu(),
      _createWifiConnectMenu(),
      _createCopyFileMenu(),
      _createInstallApkMenu(),
      _createInstallAabMenu(),
      _createClearDataMenu(),
      _createSignInfoMenu(),
      _createCustomCommandMenu(),
    ];
  }

  HomeMenu _createGetDevicesMenu() {
    return HomeMenu("获取设备列表", () async {
      var res = await _getDevicesInfo();
      _handleResultUpdate(res);
    });
  }

  HomeMenu _createIpConnectMenu() {
    return HomeMenu("主动ip无线连接（需无线连接过一次）", () async {
      var res = await _ipConnect();
      if (res.exitCode != CommandResultCode.defaultCode) {
        _handleResultUpdate(res);
        if (res.isSuccess && !res.outString.contains("empty")) {
          SmartDialog.showToast("连接成功！");
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _getDevicesInfo();
      }
    });
  }

  HomeMenu _createWifiConnectMenu() {
    return HomeMenu("无线连接设备", () async {
      var res = await _wifiConnect();
      _handleResultUpdate(res);
      if (res.isSuccess) {
        SmartDialog.showToast("连接成功！");
      }
      await Future.delayed(const Duration(milliseconds: 500));
      _getDevicesInfo();
    }, tagList: [MenuTag.wifiDisable, MenuTag.needDevice]);
  }

  HomeMenu _createCopyFileMenu() {
    return HomeMenu("复制文件到手机", () {
      SmartDialog.show(
          builder: (_) =>
              CopyFileDialog(deviceName: state.currentDevice.value.name));
    }, tagList: [MenuTag.needDevice]);
  }

  HomeMenu _createInstallApkMenu() {
    return HomeMenu("安装apk", () async {
      await _installApk();
    }, tagList: [MenuTag.needDevice]);
  }

  HomeMenu _createInstallAabMenu() {
    return HomeMenu("安装aab", () async {
      CommandResult? tempRes = await SmartDialog.show(
        builder: (_) => BuildAabDialog(
            device: state.currentDevice.value,
            signInfoList: state.signInfoList),
      );
      if (tempRes != null) {
        state.currentResult.value = tempRes;
        state.results.add(tempRes);
      }
    }, tagList: [MenuTag.needDevice]);
  }

  HomeMenu _createClearDataMenu() {
    return HomeMenu("清除数据", () {
      Navigator.of(Get.context!).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => ClearAppPage(),
          transitionDuration: Duration(milliseconds: 500), // 进入动画时间
          reverseTransitionDuration: Duration(milliseconds: 20) // 退出时瞬间完成
          ));
    },tagList: [MenuTag.needDevice]);
  }

  HomeMenu _createSignInfoMenu() {
    return HomeMenu("预设签名信息", () async {
      await SmartDialog.show(builder: (_) => const AddSignInfoDialog());
      _loadSignInfo();
    });
  }

  HomeMenu _createCustomCommandMenu() {
    return HomeMenu("自定义命令", () async {
      String cmdStr = "";
      await SmartDialog.show(
        builder: (_) => TextFieldDialog(
          onTextChanged: (s) => cmdStr = s,
          defaultStr: cmdStr,
        ),
      );
      if (cmdStr == "") {
        return CommandResult(
            exitCode: CommandResultCode.error,
            outString: "未知命令",
            command: cmdStr);
      }
      var command = cmdStr.split(' ');
      var res = await CommandUtils.runCommand("adb", command);
      _handleResultUpdate(res);
    });
  }

  Future<CommandResult> _getDevicesInfo() async {
    CommandResult res;
    res = CommandUtils.getDevices();
    _resolveDevices(res);
    _resolveIp();
    for (var i = 0; i < state.devices.length; ++i) {
      var device = state.devices[i];
      var res = await CommandUtils.runAdbOfDevice(
          CommandUtils.getDeviceModel, device.name);
      var brand = await CommandUtils.runAdbOfDevice(
          CommandUtils.getDeviceBrand, device.name);
      if (res.outString.isNotEmpty) {
        state.devices[i].model = res.outString;
      }
      if (brand.outString.isNotEmpty) {
        state.devices[i].brand = brand.outString;
      }
    }
    print("devices : ${state.devices}");
    if (state.devices.isNotEmpty) state.devices.refresh();
    state.currentDevice.value = AndroidDevice.init();
    state.selectedIndex.value = -1;

    //如果有设备，默认选中第一条
    if (state.devices.isNotEmpty) {
      state.selectedIndex.value = 0;
      state.currentDevice.value = state.devices[0];
    }

    return res;
  }

  void _resolveDevices(CommandResult res) {
    state.devices.clear();
    String resString = res.outString;
    RegExp regex = RegExp(
        r"(\w+)\sdevice\s|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+)\sdevice");
    var match = regex.allMatches(resString);

    for (var res in match) {
      if (res.group(1) != null) {
        // print("Serial number 1: ${res.group(1)}");
        state.devices.add(AndroidDevice(res.group(1)!));
      }
      if (res.group(2) != null) {
        // print("ip 2: ${res.group(2)}");
        state.devices.add(AndroidDevice(res.group(2)!, isWifiConnected: true));
      }
    }
  }

  ///解析设备IP
  void _resolveIp() {
    if (state.devices.isEmpty) return;
    for (int i = 0; i < state.devices.length; i++) {
      if (state.devices[i].isWifiConnected) continue;
      final ipRes = CommandUtils.getDeviceIp(deviceName: state.devices[i].name);
      state.devices[i].ip = RegexUtil.matchAdbIp(ipRes.outString);
      final list = RegexUtil.matchIp(state.devices[i].name);
      if (list.isEmpty) continue;
      String nameIp = RegexUtil.matchIp(state.devices[i].name)[0];
      state.devices[i].isWifiConnected = nameIp == state.devices[i].ip;
    }
  }

  void _loadSignInfo() async {
    state.signInfoList.clear();
    final strList = state.sp.getStringList(SPKey.stringSignInfo);
    print("length : ${strList?.length}");
    if (strList == null) return;
    for (var i = 0; i < strList.length; ++i) {
      state.signInfoList.add(SignInfo.fromJson(jsonDecode(strList[i])));
    }
    print("sign list: ${state.signInfoList}");
  }

  Future<CommandResult> _ipConnect() async {
    String connectIp = "";
    String lastIp = state.sp.getString(SPKey.stringIp) ?? "192.168.";
    await SmartDialog.show(
        builder: (_) => TextFieldDialog(
              onTextChanged: (ip) async {
                connectIp = ip;
              },
              defaultStr: lastIp,
            ));
    if (connectIp == "") return CommandResult.init();
    state.sp.setString(SPKey.stringIp, connectIp);
    return CommandUtils.runCommand(getAdbPath(), ["connect", connectIp]);
  }

  Future<CommandResult> _wifiConnect() async {
    CommandResult res;
    if (state.currentDevice.value.isUnknown)
      return CommandResult(
          exitCode: CommandResultCode.error,
          outString: "未获取到连接状态",
          command: '');
    if (state.currentDevice.value.ip == null) {
      SmartDialog.showToast("ip未知");
      return CommandResult(
          exitCode: CommandResultCode.error, outString: "ip未知", command: '');
    }
    res = await CommandUtils.runCommand(
        getAdbPath(), ["connect", state.currentDevice.value.ip!]);
    state.results.add(res);
    if (res.outString.contains("cannot connect")) {
      print("cannot connect");
      SmartDialog.showToast("默认连接失败，尝试启动adbd重连");
      res = await CommandUtils.runAdbOfDevice(
          ["tcpip", "5555"], state.currentDevice.value.name);
      state.results.add(res);
      print(res);
      res = await CommandUtils.runCommand(
          getAdbPath(), ["connect", state.currentDevice.value.ip!]);
      state.results.add(res);
      return res;
    }
    return CommandResult(
        exitCode: CommandResultCode.error, outString: "未知错误", command: '');
  }

  Future<CommandResult?> _installApk() async {
    CommandResult res;
    SmartDialog.show(
        builder: (_) => DropFileDialog(
              onSave: (isCopy, path) async {
                print("isCopy : $isCopy,path : $path");
                SmartDialog.showLoading(msg: "安装中...");
                res = await CommandUtils.runAdbOfDevice(
                    ["install", path], state.currentDevice.value.name);
                _handleResultUpdate(res);
                SmartDialog.dismiss(status: SmartStatus.loading);
                SmartDialog.dismiss(status: SmartStatus.dialog);
                if (!res.isSuccess) {
                  SmartDialog.showToast("安装失败");
                }
              },
              onInstallOpen: (isCopy, path) async {
                print("isCopy : $isCopy,path : $path");
                SmartDialog.dismiss(status: SmartStatus.dialog);
                SmartDialog.showLoading(msg: "安装中...");
                res = await CommandUtils.runAdbOfDevice(
                    ["install", path], state.currentDevice.value.name);
                state.results.add(res);
                SmartDialog.dismiss(status: SmartStatus.loading);
                if (res.outString.contains("Success")) {
                  print("install success");
                  var apkInfo = await CommandUtils.getApkInfo(path);
                  if (apkInfo == null) {
                    res = CommandResult(
                        exitCode: CommandResultCode.error,
                        outString: "",
                        errorString: "出错",
                        command: "aapt dump badging $path");
                  } else {
                    print("apkInfo $apkInfo");
                    res = await CommandUtils.launchApplication(
                        state.currentDevice.value.name, apkInfo.packageName!,
                        launchActivityName: apkInfo.launchActivity);
                  }
                  state.currentResult.value = res;
                  state.results.add(res);
                }
                state.currentResult.refresh();
                SmartDialog.dismiss(status: SmartStatus.loading);
              },
              onInstallOpenAndCopy: (isCopy, path) async {
                print("isCopy : $isCopy,path : $path");
                SmartDialog.dismiss(status: SmartStatus.dialog);
                SmartDialog.showLoading(msg: "安装中...");
                res = await CommandUtils.runAdbOfDevice(
                    ["install", path], state.currentDevice.value.name);
                state.results.add(res);
                SmartDialog.dismiss(status: SmartStatus.loading);
                if (res.outString.contains("Success")) {
                  print("install success");
                  var apkInfo = await CommandUtils.getApkInfo(path);
                  if (apkInfo == null) {
                    res = CommandResult(
                        exitCode: CommandResultCode.error,
                        outString: "",
                        errorString: "出错",
                        command: "aapt dump badging $path");
                  } else {
                    print("apkInfo $apkInfo");
                    res = await CommandUtils.launchApplication(
                        state.currentDevice.value.name, apkInfo.packageName!,
                        launchActivityName: apkInfo.launchActivity);
                  }
                  state.currentResult.value = res;
                  state.results.add(res);
                  res = await CommandUtils.pushFile2APKDirectory(
                      state.currentDevice.value.name, XFile(path));
                  if (res.isSuccess) {
                    SmartDialog.showToast("复制成功");
                  } else {
                    SmartDialog.showToast("复制失败");
                  }
                }
                state.currentResult.refresh();
                SmartDialog.dismiss(status: SmartStatus.loading);
              },
            ));
    return null;
  }

  void _handleResultUpdate(CommandResult res) {
    state.currentResult.value = res;
    state.results.add(res);
    state.currentResult.refresh();
  }
}

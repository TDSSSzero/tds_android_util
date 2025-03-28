import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/common/regex_util.dart';
import 'package:tds_android_util/model/apk_info.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'package:tds_android_util/utils/file_util.dart';
import 'package:path/path.dart' as p;

/// author TDSSS
abstract class CommandUtils {

  static const getDeviceBrand = ["shell","getprop","ro.product.brand"];
  static const getDeviceModel = ["shell","getprop","ro.product.model"];
  static const getDeviceMarketName = ["shell","getprop","ro.product.marketname"];
  static const adb = "adb";
  static const pull = "pull";
  static const push = "push";
  static const devices = "devices";

  ///获取当前adb连接的所有设备
  static CommandResult getDevices(){
    var result = Process.runSync(getAdbPath(), ['devices']);
    var cr = CommandResult.fromResult(result,"$adb $devices");
    print('result: $cr');
    if (!cr.isSuccess) {
      return CommandResult(
          exitCode: CommandResultCode.error,
          outString: "查找设备命令出错",
          command: "adb devices");
    }
    return cr;
  }

  static Future<CommandResult> runCommand(String target,List<String> command)async{
    var result = await Process.run(target, command,stdoutEncoding: utf8,stderrEncoding: utf8);
    print("result: ${CommandResult.fromResult(result,"$target $command")}");
    return CommandResult.fromResult(result,"$target $command");
  }

  static Future<CommandResult> runCommandOfDevice(String target,List<String> command,String deviceName)async{
    var list = ["-s",deviceName];
    list.addAll(command);
    var result = await Process.run(target, list,stdoutEncoding: utf8);
    // print("command : $target $command, result: ${CommandResult.fromResult(result)}");
    return CommandResult.fromResult(result,"$target $command");
  }
  static Future<CommandResult> runAdbOfDevice(List<String> command,String deviceName)async{
    var list = ["-s",deviceName];
    list.addAll(command);
    var result = await Process.run(getAdbPath(), list,stdoutEncoding: utf8);
    StringBuffer commandStr = StringBuffer();
    commandStr.writeAll(list," ");
    CommandResult commandResult = CommandResult.fromResult(result,"adb $commandStr");
    print("result: $commandResult");
    return commandResult;
  }

  static Future<Process> startAdbOfDevice(List<String> command,String deviceName)async{
    var list = ["-s",deviceName];
    list.addAll(command);
    var result = await Process.start(getAdbPath(), list);
    // print(result.stdout);
    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);
    return result;
  }

  static CommandResult getDeviceIp({String? deviceName}){
    if(deviceName != null){
      var result = Process.runSync(getAdbPath(), ['-s',deviceName,'shell','ip','route']);
      var cr = CommandResult.fromResult(result,"adb -s $deviceName shell ip route");
      print("command : [shell,ip,route], result: $cr");
      return cr;
    }
    var result = Process.runSync(getAdbPath(), ['shell','ip','route']);
    var cr = CommandResult.fromResult(result,"adb shell ip route");
    print("command : [shell,ip,route], result: $cr");
    return cr;
  }

  static Future<ApkInfo?> getApkInfo(String apkPath)async{
    if(containsNonASCII(apkPath)){
      print("包含特殊字符");
      final tempPath = await getTempPath();
      final tempApkPath = p.join(tempPath,p.basename(apkPath));
      bool isExists = File(tempApkPath).existsSync();
      if(!isExists){
        bool isCopy = await FileUtil.copyTo(apkPath, tempApkPath);
        if(!isCopy){
          return null;
        }
        isExists = true;
      }
      apkPath = tempApkPath;
    }
    print("get apkinfo path : $apkPath");
    var result = await Process.run(getAaptPath(), ["dump","badging",apkPath],stdoutEncoding: utf8,stderrEncoding: utf8);
    final resOut = result.stdout;
    print("res : ${result.stdout}");
    print("res error : ${result.stderr}");
    final packageName = RegexUtil.matchString(resOut, RegexUtil.packageName);
    final launchActivity = RegexUtil.matchString(resOut, RegexUtil.launchActivity);
    print("packageName : $packageName, launchActivity : $launchActivity");
    return ApkInfo(packageName, launchActivity);
  }

  static Future<CommandResult> launchApplication(String deviceName,String packageName,{String? launchActivityName}){
    launchActivityName ??= ".MainActivity";
    return runAdbOfDevice(["shell","am","start","$packageName/$launchActivityName"], deviceName);
  }

  static Future<CommandResult> pushFile2APKDirectory(String deviceName,XFile file){
    return runAdbOfDevice(["push",file.path,"/sdcard/APK/${file.name}"], deviceName);
  }

  static Future<CommandResult> pullFile2Directory(String deviceName,String fileName,String savePath){
    final path = "\\sdcard\\apk\\$fileName";
    savePath = savePath.replaceAll('\n', '');
    print("command pull copy $path to $savePath");
    return runAdbOfDevice(["pull",path,savePath], deviceName);
  }

  static Future<CommandResult> getDirAPKFileNameList(String deviceName){
    return runAdbOfDevice(["shell","ls","/sdcard/apk"], deviceName);
  }

  static Future<CommandResult> clearAppData(String package,String deviceName){
    return runAdbOfDevice(["shell","pm","clear",package], deviceName);
  }

}
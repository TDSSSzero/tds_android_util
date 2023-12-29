import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/common/regex_util.dart';
import 'package:tds_android_util/model/apk_info.dart';
import 'package:tds_android_util/model/command_result.dart';

/// author TDSSS
abstract class CommandUtils {

  static const getDeviceModel = ["shell","getprop","ro.product.model"];
  static const getDeviceMarketName = ["shell","getprop","ro.product.marketname"];

  static CommandResult getDevices(){
    var result = Process.runSync(getAdbPath(), ['devices']);
    var cr = CommandResult.fromResult(result,"adb devices");
    print('result: $cr');
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
    var result = await Process.run(target, list);
    // print("command : $target $command, result: ${CommandResult.fromResult(result)}");
    return CommandResult.fromResult(result,"$target $command");
  }
  static Future<CommandResult> runAdbOfDevice(List<String> command,String deviceName)async{
    var list = ["-s",deviceName];
    list.addAll(command);
    var result = await Process.run(getAdbPath(), list);
    print("result: ${CommandResult.fromResult(result,"adb $command")}");
    return CommandResult.fromResult(result,"adb $command");
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

  static Future<ApkInfo> getApkInfo(String apkPath)async{
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

}
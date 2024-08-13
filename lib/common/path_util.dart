import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// author TDSSS

Future<String> getTempPath()async{
  final tempDir = await getTemporaryDirectory();
  return p.join(tempDir.path,"tds_android_util");
}

String getAssetsPath(){
  String dirPath = p.dirname(Platform.script.toFilePath());
  print("script path: $dirPath");
  String assetsPath = p.join(dirPath,"data","flutter_assets","assets");
  if(kDebugMode){
    assetsPath = p.join(dirPath,"assets");
  }
  return assetsPath;
}

String getAdbPath(){
  final assetsPath = getAssetsPath();
  String adbPath = p.join(assetsPath,"platform_tools","adb.exe");
  // print("is exists : ${File(adbPath).existsSync()}");
  return adbPath;
}

String getBundleToolPath(){
  final assetsPath = getAssetsPath();
  String bundleToolPath = p.join(assetsPath,"bundle_tool","bundletool-all-1.15.6.jar");
  return bundleToolPath;
}

String getAaptPath(){
  final assetsPath = getAssetsPath();
  String aaptPath = p.join(assetsPath,"build_tool_34.0.0","aapt.exe");
  // print("is exists : ${File(aaptPath).existsSync()}");
  return aaptPath;
}

bool containsNonASCII(String inputStr){
  // 定义一个正则表达式来匹配非ASCII字符
  final nonASCIIRegExp = RegExp(r'[^\x00-\x7F]');
  // 检查输入字符串中是否包含非ASCII字符
  return nonASCIIRegExp.hasMatch(inputStr);
}
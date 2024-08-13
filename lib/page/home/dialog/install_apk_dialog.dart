import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/common/command_util.dart';
import 'package:tds_android_util/function.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'package:tds_android_util/page/home/drop_file_dialog.dart';

class InstallApkDialog extends StatefulWidget {
  const InstallApkDialog({
    super.key,
    required this.deviceName,
    required this.onSave,
    required this.onInstallOpen,
  });

  final SingleCallback<CommandResult> onSave;
  final SingleCallback<List<CommandResult>> onInstallOpen;
  final String deviceName;

  @override
  State<InstallApkDialog> createState() => _InstallApkDialogState();
}

class _InstallApkDialogState extends State<InstallApkDialog> {

  @override
  Widget build(BuildContext context) {
    return DropFileDialog(
        onSave: (isCopy, path) async{
          print("isCopy : $isCopy,path : $path");
          SmartDialog.dismiss(status: SmartStatus.dialog);
          SmartDialog.showLoading(msg: "安装中...");
          final res = await CommandUtils.runAdbOfDevice(["install",path], widget.deviceName);
          SmartDialog.dismiss(status: SmartStatus.loading);
          widget.onSave(res);
        },
        onInstallOpen: (isCopy, path) async{
          print("isCopy : $isCopy,path : $path");
          SmartDialog.dismiss(status: SmartStatus.dialog);
          SmartDialog.showLoading(msg: "安装中...");
          final resList = <CommandResult>[];
          final res = await CommandUtils.runAdbOfDevice(["install",path], widget.deviceName);
          SmartDialog.dismiss(status: SmartStatus.loading);
          resList.add(res);
          if(res.outString.contains("Success")){
            print("install success");
            var apkInfo = await CommandUtils.getApkInfo(path);
            if(apkInfo == null){
              final launchAppRes = CommandResult(exitCode: CommandResultCode.error, outString: "",errorString: "出错",command: "aapt dump badging $path");
              resList.add(launchAppRes);
            }else{
              print("apkInfo $apkInfo");
              final launchAppRes = await CommandUtils.launchApplication(widget.deviceName, apkInfo.packageName!,launchActivityName: apkInfo.launchActivity);
              resList.add(launchAppRes);
            }
          }else{
            final launchAppRes = CommandResult(exitCode: CommandResultCode.error, outString: "",errorString: "出错",command: "aapt dump badging $path");
            resList.add(launchAppRes);
          }
          widget.onInstallOpen(resList);
          SmartDialog.dismiss(status: SmartStatus.loading);

        });
  }
}

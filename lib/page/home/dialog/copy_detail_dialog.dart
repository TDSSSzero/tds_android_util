import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/common/command_util.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

import '../../../model/command_result.dart';

class CopyDetailDialog extends StatefulWidget {

  final List<XFile> files;
  final String deviceName;

  const CopyDetailDialog({super.key,required this.files,required this.deviceName});

  @override
  State<CopyDetailDialog> createState() => _CopyDetailDialogState();
}

class _CopyDetailDialogState extends State<CopyDetailDialog> {

  List<CommandResult> results = [];
  List<String?> resultsString = [];

  @override
  void initState() {
    super.initState();
    resultsString = List.generate(widget.files.length, (index) => null);
    _copyFile();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(child: ListView.builder(
      itemCount: widget.files.length,
        itemBuilder: _buildCopyDetail
    ));
  }

  Widget _buildCopyDetail(BuildContext context,int index){
    return ListTile(title: Text(widget.files[index].name),trailing: Text(resultsString[index] ?? "等待复制"),);
  }

  void _copyFile()async{
    SmartDialog.showLoading(msg: "开始复制..");
    for (var i = 0; i < widget.files.length; ++i) {
      var file = widget.files[i];
      final res = await CommandUtils.runAdbOfDevice(["push",file.path,"/sdcard/APK/${file.name}"], widget.deviceName);
      if(res.isSuccess){
        resultsString[i] = "成功";
      }else{
        resultsString[i] = "失败";
      }
      setState(() {});
    }
    SmartDialog.dismiss(status: SmartStatus.loading);
  }

}

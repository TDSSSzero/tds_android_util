import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/common/command_util.dart';
import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

class LookFileDialog extends StatefulWidget {

  final String deviceName;
  final String outStr;

  const LookFileDialog({super.key,required this.deviceName,required this.outStr});

  @override
  State<LookFileDialog> createState() => _LookFileDialogState();
}

class _LookFileDialogState extends State<LookFileDialog> {
  final List<XFile> _list = [];
  int selectedIndex = -1;

  final List<bool> _checkedList = [];
  final List<bool> _hoverList = [];

  bool get isHaveSelected {
    for (var b in _checkedList) {
      if(b)return true;
    }
    return false;
  }

  List<XFile> get selectedFiles{
    final List<XFile> list = [];
    for (var i = 0; i < _checkedList.length; ++i) {
      if(_checkedList[i]){
        list.add(_list[i]);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    final list = widget.outStr.split("\n");
    for(var name in list){
      if(name.isEmpty) continue;
      print("file name : $name");
      _list.add(XFile(name));
      _hoverList.add(false);
      _checkedList.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 600,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                // borderRadius: BorderRadius.circular(20)
              ),
              child: ListView.builder(
                itemBuilder: _buildItem,
                itemCount: _list.length,
              ),
            ),
            const Text("默认复制文件到本文件目录 '/download' 下"),
            ElevatedButton(
                onPressed: !isHaveSelected ? null :() async{
                  SmartDialog.showLoading(msg: "复制中...");
                  await _copyFile();
                  SmartDialog.dismiss();
                },
                child: const Text("复制")),
          ],
        )
    );
  }

  Widget _buildItem(BuildContext context,int index){
    Color? color = null;
    if(_hoverList[index]){
      color = Colors.greenAccent;
    }else if(_checkedList[index]){
      color = Colors.blue;
    }
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoverList[index] = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hoverList[index] = false;
        });
      },
      child: ListTile(
        onTap: (){
          _checkedList[index] = !_checkedList[index];
          setState(() {

          });
        },
        title: Text(
                  _list[index].name,
                  style: TextStyle(color: color),
                ),
        trailing: _checkedList[index] ? const Icon(Icons.check) : null,
      ),
    );
  }

  Future<void> _copyFile() async{
    final savePath = await _getSavePath();
    final list = selectedFiles;
    for (var file in list) {
      final targetPath = "$savePath\\${file.name}";
      final res = CommandUtils.pullFile2Directory(widget.deviceName, file.name, targetPath);
      print("copy ${file.name} to $targetPath , res : $res");
    }
  }

  Future<String> _getSavePath() async{
    final path = getAssetsPath();
    Directory dir = Directory(path);
    final targetPath = "${dir.parent.path}\\download";
    final targetDir = Directory(targetPath);
    if(!targetDir.existsSync()){
      targetDir.createSync();
    }
    print(targetDir);
    return targetPath;
  }

}
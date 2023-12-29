import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/common/command_util.dart';
import 'package:tds_android_util/common/file_name_ex.dart';
import 'package:tds_android_util/common/path_util.dart';
import 'package:tds_android_util/common/toast_util.dart';
import 'package:tds_android_util/model/android_device.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

import '../../../model/sign_info.dart';

class BuildAabDialog extends StatefulWidget {

  final AndroidDevice device;
  final List<SignInfo> signInfoList;

  const BuildAabDialog({super.key,required this.device,required this.signInfoList});

  @override
  State<BuildAabDialog> createState() => _BuildAabDialogState();
}

class _BuildAabDialogState extends State<BuildAabDialog> {

  final List<XFile> _aabFileList = [];
  final List<XFile> _apksFileList = [];
  final List<XFile> _keystoreFileList = [];
  String? keystorePassword;
  String? alias;
  String? password;
  int selectedIndex = -1;
  String? apksPath;

  bool _dragging = false;

  bool get isHaveFile => _aabFileList.isNotEmpty && _keystoreFileList.isNotEmpty;

  int dropIndex = -1;

  final kspCtrl = TextEditingController();
  final aliasCtrl = TextEditingController();
  final kpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("signInfoList.isNotEmpty : ${widget.signInfoList.isNotEmpty}");
    return DialogBase(
        child: ListView(
          children: [
            _buildRow("预设", DropdownMenu<int>(
            dropdownMenuEntries:
                List.generate(
                    widget.signInfoList.length,
                        (index) => DropdownMenuEntry(value: index, label: widget.signInfoList[index].alias,)
                ),
              onSelected: (selectedIndex){
                  dropIndex = selectedIndex ?? -1;
                  if(dropIndex == -1) return;
                  kspCtrl.text = widget.signInfoList[dropIndex].storePassword;
                  aliasCtrl.text = widget.signInfoList[dropIndex].alias;
                  kpCtrl.text = widget.signInfoList[dropIndex].keyPassword;
                  keystorePassword =  widget.signInfoList[dropIndex].storePassword;
                  alias =  widget.signInfoList[dropIndex].alias;
                  password =  widget.signInfoList[dropIndex].keyPassword;
                  _keystoreFileList.clear();
                  _keystoreFileList.add(XFile(widget.signInfoList[dropIndex].filePath));
                  setState(() {});
              },
              width: 300,
            ),height:50
            ),
            _buildRow("aab文件：", _buildOneDrag("aab", _aabFileList,isCustomType: true),height: 130),
            _buildRow("签名文件：",_buildOneDrag("keystore", _keystoreFileList),height: 150),
            _buildRow("签名文件密码(KeyStorePsd)：",
                TextField(
                  controller: kspCtrl,
                onChanged: (s){keystorePassword = s;setState(() {});}
            ), height: 40),
            _buildRow("签名别名(KeyAlias)：            ",
                TextField(
                  controller: aliasCtrl,
                onChanged: (s){alias = s;setState(() {});}
            ),height: 40),
            _buildRow("签名密码(KeyPassword)：    ",
                TextField(
                  controller: kpCtrl,
                onChanged: (s){password = s;setState(() {});}
            ),height: 40),
            Container(
              alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text("构建apks存储在aab相同路径下")
            ),
            _buildButton(onPressed: isHaveFile ? _onBuildApks : null,msg: "构建apks"),
            _buildButton(onPressed: isHaveFile ? _buildAndInstall : null,msg: "构建apks并安装"),
            const Center(child: Text("↓↓↓↓↓↓↓↓↓↓↓↓ 单独安装apks看下方 ↓↓↓↓↓↓↓↓↓↓↓↓")),
            _buildRow("apks文件：", _buildOneDrag("apks", _apksFileList,isCustomType: true),height: 150),
            _buildButton(onPressed: _apksFileList.isNotEmpty ? _installApks : null,msg: "安装apks"),
            // _buildButton(onPressed: isHaveFile ? _buildInstallOpen : null,msg: "构建针对设备的apk并安装打开"),
            ],));
  }

  Widget _buildRow(String text,Widget child,{required double height,double? width}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(text),
        Container(alignment: Alignment.center,width: width ?? 300,height: height,child: child)
      ],
    );
  }

  Widget _buildButton({required void Function()? onPressed,required String msg}){
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(onPressed: onPressed,child: Text(msg),),
    );
  }

  Widget _buildOneDrag(String type,List<XFile> list,{bool isCustomType = false}){
    return DropTarget(
      onDragDone: (detail) {
        final files = detail.files;
        if(files.length != 1){
          SmartDialog.showToast("请放入1个文件");
          return;
        }
        list.add(files[0]);
        setState(() {});
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
          ),
          child: list.isEmpty
              ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: ()async{
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: isCustomType ? FileType.custom : FileType.any,
                    allowedExtensions: isCustomType ? [type] : null);
                if (result != null) {
                  final fileList = result.paths.map((e) => XFile(e!)).toList();
                  list.add(fileList[0]);
                  setState(() {});
                } else {
                  // User canceled the picker
                }
              }, child: const Text("选择文件")),
              Text("拖拽$type文件到这里"),
              Icon(Icons.add_rounded,size: 20,color: Colors.grey.withOpacity(0.6))
            ],
          ))
              : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(list[0].name),
                );
              }
          )
      ),
    );
  }

  Future<CommandResult?> _buildApks()async{
    String aabPath = _aabFileList[0].path;
    final aabFile = XFile(aabPath);
    String? bundleToolPath = getBundleToolPath();
    print("aabPath : $aabPath");
    print("bundleToolPath : $bundleToolPath");
    print("output : ${p.join(File(aabPath).parent.path,aabFile.apksName)}");
    print("ks : ${_keystoreFileList[0].path}");
    print("keystorePassword : $keystorePassword");
    print("alias : $alias");
    print("password : $password");
    if(keystorePassword != "" && alias != "" && password != ""){
      apksPath = p.join(File(aabPath).parent.path,aabFile.apksName);
      return await CommandUtils.runCommand(
          "java",
          [
            "-jar",
            bundleToolPath,
            "build-apks",
            "--bundle=$aabPath",
            "--output=$apksPath",
            "--overwrite",
            "--ks=${_keystoreFileList[0].path}",
            "--ks-pass=pass:$keystorePassword",
            "--ks-key-alias=$alias",
            "--key-pass=pass:$password"
          ]
      );
    }else{
      SmartDialog.showToast("参数有误");
      return null;
    }
  }

  void _onBuildApks()async{
    SmartDialog.showLoading(msg: "构建中...");
    final res = await _buildApks();
    SmartDialog.dismiss(status: SmartStatus.loading);
    res == null ? SmartDialog.showToast("构建失败") : SmartDialog.showToast("构建成功！");
    SmartDialog.dismiss(status: SmartStatus.dialog,result: res);
  }

  void _buildAndInstall() async{
    SmartDialog.showLoading(msg: "构建中...");
    CommandResult? res = await _buildApks();
    await SmartDialog.dismiss(status: SmartStatus.loading);
    if(res == null){
      SmartDialog.showToast("构建失败");
      return;
    }
    await SmartDialog.showToast("构建成功！");
    String? bundleToolPath = getBundleToolPath();
    if(apksPath == null){
      SmartDialog.showToast("参数有误");
      return;
    }
    SmartDialog.showLoading(msg: "安装中...");
    res = await CommandUtils.runCommand(
        "java",
        [
          "-jar",
          bundleToolPath,
          "install-apks",
          "--device-id=${widget.device.name}",
          "--apks=$apksPath",
        ]
    );
    SmartDialog.dismiss(status: SmartStatus.loading);
    SmartDialog.dismiss(status: SmartStatus.dialog,result: res);
    showFinishToast();
  }

  void _installApks()async{
    String? bundleToolPath = getBundleToolPath();
    SmartDialog.showLoading(msg: "安装中...");
    final res = await CommandUtils.runCommand(
        "java",
        [
          "-jar",
          bundleToolPath,
          "install-apks",
          "--device-id=${widget.device.name}",
          "--apks=${_apksFileList[0].path}",
        ]
    );
    SmartDialog.dismiss(status: SmartStatus.loading);
    SmartDialog.dismiss(status: SmartStatus.dialog,result: res);
    showFinishToast();
  }

  void _buildInstallOpen() async{

  }

}

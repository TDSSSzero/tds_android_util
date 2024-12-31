import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tds_android_util/common/sp_key.dart';
import 'package:tds_android_util/model/sign_info.dart';

import '../../../widget/dialog_base.dart';

class AddSignInfoDialog extends StatefulWidget {
  const AddSignInfoDialog({super.key});

  @override
  State<AddSignInfoDialog> createState() => _AddSignInfoDialogState();
}

class _AddSignInfoDialogState extends State<AddSignInfoDialog> {
  XFile? keystoreFile;
  String? keystorePassword;
  String? alias;
  String? password;
  String? infoName;
  bool _dragging = false;
  late final SharedPreferences sp;
  List<SignInfo> list = [];

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController kspCtrl = TextEditingController();
  TextEditingController aliasCtrl = TextEditingController();
  TextEditingController kpCtrl = TextEditingController();

  @override
  void initState() {
    _loadSp();
    super.initState();
  }

  void _loadSp() async {
    sp = await SharedPreferences.getInstance();
    final tempList = sp.getStringList(SPKey.stringSignInfo);
    if (tempList == null) return;
    list.addAll(tempList.map((e) => SignInfo.fromJson(jsonDecode(e))).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text("已经添加的预设，点击垃圾桶icon可以删除",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildInfoList(),
            const Divider(),
            _buildRow(
                "预设名称：    ",
                TextField(
                    controller: nameCtrl,
                    onChanged: (s) {
                      infoName = s;
                      setState(() {});
                    })),
            _buildRow("签名文件：", _buildOneDrag("keystore"), height: 120),
            _buildRow(
                "签名文件密码(KeyStorePsd)：",
                TextField(
                    controller: kspCtrl,
                    onChanged: (s) {
                      keystorePassword = s;
                      setState(() {});
                    })),
            _buildRow(
                "签名别名(KeyAlias)：            ",
                TextField(
                    controller: aliasCtrl,
                    onChanged: (s) {
                      alias = s;
                      setState(() {});
                    })),
            _buildRow(
                "签名密码(KeyPassword)：    ",
                TextField(
                    controller: kpCtrl,
                    onChanged: (s) {
                      password = s;
                      setState(() {});
                    })),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _onAddInfo,
                    child: const Text("添加预设")),
                ElevatedButton(
                    onPressed: () {
                      SmartDialog.dismiss();
                    },
                    child: const Text("关闭")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoList() {
    Widget child = const SizedBox();
    if (list.isNotEmpty) {
      return Container(
        alignment: Alignment.center,
        height: 150,
        child: ListView(
          children: List.generate(list.length, _buildInfoItem),
        ),
      );
    }
    return child;
  }

  Widget _buildInfoItem(int index) {
    var data = list[index];
    var name = data.infoName;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
              vertical: 5, horizontal: constraints.maxWidth * 0.2),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.green)),
            child: Material(
                child: ListTile(
              onTap: () => _onTapInfo(index),
              title: Text("预设名：$name 签名别名: ${data.alias}"),
              trailing: IconButton(
                  onPressed: () => _onDeleteInfo(index),
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  )),
            )),
          ),
        );
      },
    );
  }

  Widget _buildRow(String text, Widget child,
      {double height = 40, double? width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(width: 300,child: Text(text,style: const TextStyle(fontSize: 18),)),
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: width ?? 300,
            height: height,
            child: child)
      ],
    );
  }

  Widget _buildOneDrag(String type, {bool isCustomType = false}) {
    return DropTarget(
      onDragDone: (detail) {
        final files = detail.files;
        if (files.length != 1) {
          SmartDialog.showToast("请放入1个文件");
          return;
        }
        keystoreFile = files[0];
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
        width: 300,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color:
                _dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
          ),
          child: keystoreFile == null
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  type: isCustomType
                                      ? FileType.custom
                                      : FileType.any,
                                  allowedExtensions:
                                      isCustomType ? [type] : null);
                          if (result != null) {
                            final fileList =
                                result.paths.map((e) => XFile(e!)).toList();
                            keystoreFile = fileList[0];
                            setState(() {});
                          } else {
                            // User canceled the picker
                          }
                        },
                        child: const Text("选择文件")),
                    Text("拖拽$type文件到这里"),
                    Icon(Icons.add_rounded,
                        size: 20, color: Colors.grey.withOpacity(0.6))
                  ],
                ))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(keystoreFile!.name),
                )),
    );
  }

  void _onTapInfo(int index) {
    var data = list[index];
    infoName = data.infoName ?? "";
    alias = data.alias;
    password = data.storePassword;
    keystorePassword = data.keyPassword;

    nameCtrl.text = data.infoName ?? "";
    kspCtrl.text = data.storePassword;
    aliasCtrl.text = data.alias;
    kpCtrl.text = data.keyPassword;
    keystoreFile = null;
    keystoreFile = XFile(data.filePath);
    setState(() {});
  }

  void _onDeleteInfo(int index) {
    SmartDialog.show(
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50),
        width: 300,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "是否要删除预设？",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      list.removeAt(index);
                      final jsonList =
                          list.map((e) => jsonEncode(e.toJson())).toList();
                      sp.setStringList(SPKey.stringSignInfo, jsonList);
                      SmartDialog.dismiss();
                      setState(() {});
                    },
                    child: const Text(
                      "删除",
                      style: TextStyle(color: Colors.red),
                    )),
                ElevatedButton(
                    onPressed: () {
                      SmartDialog.dismiss();
                    },
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onAddInfo(){
    if (keystoreFile == null ||
        keystorePassword == null ||
        alias == null ||
        password == null) {
      SmartDialog.showToast("参数不正确");
      return;
    }
    final data = SignInfo(keystoreFile!.path, alias!,
        keystorePassword!, password!, infoName!);
    final json = jsonEncode(data.toJson());
    print("json : $json");
    if (!list.contains(data)) {
      list.add(data);
      final jsonList =
      list.map((e) => jsonEncode(e.toJson())).toList();
      sp.setStringList(SPKey.stringSignInfo, jsonList);
      SmartDialog.showToast("添加成功");
    } else {
      SmartDialog.showToast("存在相同签名");
    }
    setState(() {});
  }
}

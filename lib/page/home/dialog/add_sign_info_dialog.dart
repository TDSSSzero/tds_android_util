import 'dart:convert';
import 'dart:math';

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
  bool _dragging = false;
  late final SharedPreferences sp;
  List<SignInfo> list = [];

  @override
  void initState() {
    _loadSp();
    super.initState();
  }

  void _loadSp()async{
    sp = await SharedPreferences.getInstance();
    final tempList = sp.getStringList(SPKey.stringSignInfo);
    if(tempList == null) return;
    list.addAll(tempList.map((e) => SignInfo.fromJson(jsonDecode(e))).toList());
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        children: [
          const Text("已经添加的预设，点击可以删除", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          list.isNotEmpty ?
          Container(
            alignment: Alignment.center,
            height: 200,
            // color: Colors.greenAccent.withOpacity(0.2),
            child: ListView(
              children: List.generate(
                  list.length,
                      (index) => InkWell(
                        focusColor: Colors.grey,
                        hoverColor: Colors.red,
                          mouseCursor: MaterialStateMouseCursor.clickable,
                        onTap: (){
                          SmartDialog.show(builder: (context) => Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            width: 300,
                            height: 200,
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("是否要删除？"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(onPressed: (){
                                      list.removeAt(index);
                                      final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
                                      sp.setStringList(SPKey.stringSignInfo, jsonList);
                                      SmartDialog.dismiss();
                                      setState(() {

                                      });
                                    }, child: Text("删除",style: TextStyle(color: Colors.red),)),
                                    ElevatedButton(onPressed: (){
                                      SmartDialog.dismiss();
                                    }, child: Text("取消",style: TextStyle(color: Colors.lightBlueAccent),)),
                                  ],
                                )
                              ],
                            ),
                          ),);
                        },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                              // color: Color.fromARGB(255, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255)),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(color: Colors.blue)
                            ),
                              child: Text(list[index].toString()))
                      )),
            ),
          ) : const SizedBox(),
          _buildRow("签名文件：",_buildOneDrag("keystore"),height: 150),
          _buildRow("签名文件密码(KeyStorePsd)：",
              TextField(
                  onChanged: (s){keystorePassword = s;setState(() {});}
              ), height: 40),
          _buildRow("签名别名(KeyAlias)：            ",
              TextField(
                  onChanged: (s){alias = s;setState(() {});}
              ),height: 40),
          _buildRow("签名密码(KeyPassword)：    ",
              TextField(
                  onChanged: (s){password = s;setState(() {});}
              ),height: 40),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                if(keystoreFile==null||keystorePassword==null||alias==null||password==null){
                  SmartDialog.showToast("参数不正确");
                  return;
                }
                final data = SignInfo(keystoreFile!.path, alias!, keystorePassword!, password!);
                final json = jsonEncode(data.toJson());
                print("json : $json");
                if(!list.contains(data)){
                  list.add(data);
                  final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
                  sp.setStringList(SPKey.stringSignInfo, jsonList);
                  SmartDialog.showToast("添加成功");
                }else{
                  SmartDialog.showToast("存在相同签名");
                }
                setState(() {

                });
              }, child: const Text("添加预设")),
              ElevatedButton(onPressed: (){
                SmartDialog.dismiss();
              }, child: const Text("关闭")),
            ],
          )
        ],
      ),
    );
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

  Widget _buildOneDrag(String type,{bool isCustomType = false}){
    return DropTarget(
      onDragDone: (detail) {
        final files = detail.files;
        if(files.length != 1){
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
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
          ),
          child: keystoreFile == null
              ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: ()async{
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: isCustomType ? FileType.custom : FileType.any,
                    allowedExtensions: isCustomType ? [type] : null);
                if (result != null) {
                  final fileList = result.paths.map((e) => XFile(e!)).toList();
                  keystoreFile = fileList[0];
                  setState(() {});
                } else {
                  // User canceled the picker
                }
              }, child: const Text("选择文件")),
              Text("拖拽$type文件到这里"),
              Icon(Icons.add_rounded,size: 20,color: Colors.grey.withOpacity(0.6))
            ],
          ))
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(keystoreFile!.name),
          )
      ),
    );
  }
}
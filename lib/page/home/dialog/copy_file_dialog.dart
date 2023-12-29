import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/page/home/dialog/copy_detail_dialog.dart';

class CopyFileDialog extends StatefulWidget {

  final String deviceName;

  const CopyFileDialog({super.key,required this.deviceName});

  @override
  State<CopyFileDialog> createState() => _CopyFileDialogState();
}

class _CopyFileDialogState extends State<CopyFileDialog> {
  final List<XFile> _list = [];
  int selectedIndex = -1;

  bool _dragging = false;
  final List<bool> _checkedList = [];

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
  Widget build(BuildContext context) {
    return Container(
        width: 600,
        height: 600,
        alignment: Alignment.center,
        color: Colors.white,
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: ()async{
              FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
              if (result != null) {
                final fileList = result.paths.map((e) => XFile(e!)).toList();
                _list.addAll(fileList);
                _checkedList.addAll(fileList.map((e) => false));
                setState(() {});
              } else {
                // User canceled the picker
              }
            }, child: const Text("选择文件")),
            const Text("OR"),
            DropTarget(
              onDragDone: (detail) {
                final files = detail.files;
                _list.addAll(files);
                _checkedList.addAll(files.map((e) => false));
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
                  height: 300,
                  width: 500,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
                  ),
                  child: _list.isEmpty
                      ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("拖拽文件到这里"),
                      Icon(Icons.add_rounded,size: 200,color: Colors.grey.withOpacity(0.6))
                    ],
                  ))
                      : ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: (){
                              selectedIndex = index;
                              setState(() {});
                              print("file path : ${_list[index].path}");
                            },
                            title: CheckboxListTile(
                                value: _checkedList[index],
                                onChanged: (v){
                                  _checkedList[index] = v!;
                                  setState(() {

                                  });
                                  // print("isHave : $_checkedList");
                                  // print("isHave : $isHaveSelected");
                                },
                              title: Text(_list[index].name),
                            ),
                            selected: index == selectedIndex,
                            selectedColor: Colors.greenAccent,
                          ),
                        );
                      }
                  )
              ),
            ),
            const Text("默认复制文件到手机存储 '/sdcard/APK' 目录下"),
            ElevatedButton(
                onPressed: !isHaveSelected ? null :(){
                  SmartDialog.dismiss();
                  final paths = selectedFiles;
                  if(paths.isEmpty)return;
                  SmartDialog.show(builder: (_) => CopyDetailDialog(files: selectedFiles,deviceName: widget.deviceName));
                },
                child: const Text("复制")),
          ],
        )
    );
  }
}
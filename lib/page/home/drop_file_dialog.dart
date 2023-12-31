import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tds_android_util/function.dart';

class DropFileDialog extends StatefulWidget {

  final TwiceCallback<bool,String> onSave;
  final TwiceCallback<bool,String> onInstallOpen;

  const DropFileDialog({super.key,required this.onSave,required this.onInstallOpen});

  @override
  State<DropFileDialog> createState() => _DropFileDialogState();
}

class _DropFileDialogState extends State<DropFileDialog> {

  final List<XFile> _list = [];
  int selectedIndex = -1;

  bool _dragging = false;
  bool _isCopy = false;

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
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['apk']
              );
              if (result != null) {
                // File file = File(result.files.single.path!);
                final xFile = XFile(result.files.single.path!);
                _list.add(xFile);
                print("file : ${xFile.path}");
                setState(() {});
              } else {
                // User canceled the picker
              }
            }, child: const Text("选择文件")),
            const Text("OR"),
            DropTarget(
              onDragDone: (detail) {
                final files = detail.files;
                for(var file in files){
                  int index = file.name.lastIndexOf(".");
                  if(index != -1){
                    String type = file.name.substring(index + 1);
                    print("type : $type");
                    if(type == "apk"){
                      _list.add(file);
                    }
                  }
                }
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
                            title: Text(_list[index].name),
                          selected: index == selectedIndex,
                          selectedColor: Colors.greenAccent,
                        ),
                      );
                    }
                )
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     const Text("是否复制apk到手机存储 '/sdcard/APK' 目录下"),
            //     Checkbox(value: _isCopy,onChanged: (b){_isCopy = b!;setState(() {});}),
            //   ],
            // ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: selectedIndex == -1 ? null :()=>widget.onSave(_isCopy,_list[selectedIndex].path),
                    child: const Text("安装")),
                ElevatedButton(
                    onPressed: selectedIndex == -1 ? null :()=>widget.onInstallOpen(_isCopy,_list[selectedIndex].path),
                    child: const Text("安装并打开")),
              ],
            )
          ],
        )
    );
  }
}

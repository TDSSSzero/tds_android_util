import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../function.dart';

class DropFileArea extends StatefulWidget {
  const DropFileArea({
    super.key,
    required this.actionFileCallback,
    required this.dropPathCallback,
    required this.checkDetailCallback,
    this.removeFileCallback,
    this.desc
  });
  final SingleCallback<String> actionFileCallback;
  final SingleCallback<String> dropPathCallback;
  final SingleCallback<String>? removeFileCallback;
  final VoidCallback checkDetailCallback;
  final String? desc;

  @override
  State<DropFileArea> createState() => _DropFileAreaState();
}

class _DropFileAreaState extends State<DropFileArea> {
  final List<XFile> _list = [];
  int selectedIndex = -1;
  final typeEx = "xlsx";

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom, allowedExtensions: [typeEx]);
              if (result != null) {
                final xFile = XFile(result.files.single.path!);
                _list.add(xFile);
                checkCount();
                print("file : ${xFile.path}");
                widget.dropPathCallback(xFile.path);
                setState(() {});
              } else {
                // User canceled the picker
              }
            },
            child: const Text("选择文件")),
        const SizedBox(height: 30),
        DropTarget(
          onDragDone: (detail) {
            final files = detail.files;
            for (var file in files) {
              int index = file.name.lastIndexOf(".");
              if (index != -1) {
                String type = file.name.substring(index + 1);
                if (type == typeEx) {
                  _list.add(file);
                  checkCount();
                  widget.dropPathCallback(file.path);
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
              height: 180,
              // width: 500,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: _dragging
                    ? Theme.of(context).secondaryHeaderColor
                    : Colors.transparent,
              ),
              child: _list.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: "",
                                style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold),
                              children: [
                                const TextSpan(text: "拖拽"),
                                TextSpan(text: widget.desc,style: const TextStyle(color: Colors.green)),
                                const TextSpan(text: "文件到这里"),
                              ]
                            )
                        ),
                        Icon(Icons.add_rounded,
                            size: 80, color: Theme.of(context).primaryColorLight)
                      ],
                    ))
                  : ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              selectedIndex = index;
                              setState(() {});
                              print("file path : ${_list[index].path}");
                            },
                            leading: Checkbox(value: selectedIndex == index, onChanged: (b){}),
                            title: Text(_list[index].name),
                            trailing: IconButton(onPressed: (){
                              widget.removeFileCallback?.call(_list[index].path);
                              _list.removeAt(index);
                              selectedIndex = -1;
                              setState(() {

                              });
                            }, icon: Icon(Icons.delete_forever,color: Colors.red.withOpacity(0.7))),
                            selected: index == selectedIndex,
                            // selectedColor: Colors.blueAccent.shade700,
                          ),
                        );
                      })),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: selectedIndex == -1
                ? null
                : () => widget.actionFileCallback(_list[selectedIndex].path),
            child: const Text("读取")),
        const SizedBox(height: 10),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton(onPressed: selectedIndex == -1 ? null : widget.checkDetailCallback, child: const Text("详情")))
      ],
    );
  }

  void checkCount() {
    if (_list.isNotEmpty && _list.length == 1) {
      selectedIndex = 0;
      setState(() {});
    }
  }
}

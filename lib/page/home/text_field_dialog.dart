import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/function.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

class TextFieldDialog extends StatefulWidget {

  final SingleCallback<String> onTextChanged;
  final String? defaultStr;

  const TextFieldDialog({
    super.key,
    required this.onTextChanged,
    this.defaultStr
  });

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {

  String str = "";
  late final TextEditingController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = TextEditingController(text: widget.defaultStr);
    str = widget.defaultStr ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: TextField(
              controller: ctrl,
              onChanged: (s){
                str = s;
                setState(() {

                });
              },
              onEditingComplete: (){
                if(str != ""){
                  widget.onTextChanged(str);
                  SmartDialog.dismiss();
                }
              },
            ),
          ),
          const SizedBox(height: 100),
          ElevatedButton(onPressed: (){
            if(str != ""){
              widget.onTextChanged(str);
              SmartDialog.dismiss();
            }
          }, child: const Text("提交"))
        ],
      ),
    );
  }
}
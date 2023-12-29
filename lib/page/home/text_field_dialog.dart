import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tds_android_util/function.dart';
import 'package:tds_android_util/widget/dialog_base.dart';

class TextFieldDialog extends StatefulWidget {

  final SingleCallback<String> onTextChanged;

  const TextFieldDialog({super.key,required this.onTextChanged});

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {

  String str = "";

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: TextField(
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
          }, child: const Text("连接"))
        ],
      ),
    );
  }
}
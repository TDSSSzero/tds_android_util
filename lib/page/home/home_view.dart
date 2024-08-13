import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/common/config.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;

  bool get isSuccess => state.currentResult.value.isSuccess;

  bool get isHaveResult => state.results.isNotEmpty;

  static const logTitle = "日志信息";
  static const notice = "注：文件路径中不要包含空格";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(() {
                            return ListView(
                              children: [
                                const Text("设备列表",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center),
                                ..._buildDeviceInfo()
                              ],
                            );
                          }),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 50,
                                        mainAxisSpacing: 15),
                                itemBuilder: _buildMenuItem,
                                itemCount: logic.menuString.length,
                              ))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                state.currentResult.value =
                                    CommandResult.init();
                                state.results.clear();
                              },
                              icon: const Icon(Icons.delete_forever_rounded),
                              color: Colors.red),
                          Expanded(
                              child: Obx(() => isHaveResult
                                  ? _buildResultInfo()
                                  : const Center(
                                      child: Text(logTitle,
                                          style: TextStyle(fontSize: 22))))),
                          const SizedBox(),
                        ],
                      ),
                    )),
                const Text("version : ${Config.version}")
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultInfo() {
    return SingleChildScrollView(
      child: Obx(() {
        return Column(
          children: [
            const Text(logTitle, style: TextStyle(fontSize: 22)),
            Text('当前已执行${state.results.length}条命令,单击复制命令'),
            const Divider(color: Colors.black,),
            _buildCommandRes(state.currentResult.value),
            const Divider(color: Colors.black,),
            const Text("全部命令："),
            ListView.separated(
              itemCount: state.results.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => Center(
                child: _buildCommandRes(state.results[index], index),
              ),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            )
          ],
        );
      }),
    );
  }

  Widget _buildCommandRes(CommandResult res, [int index = -1]) {
    String indexResStr = index == -1 ? "最后命令执行res" : "第${index + 1}条命令执行res ";
    String indexStr = index == -1 ? "最后命令 :" : "第${index + 1}条命令 : ";
    String resStr = res.outString.trim();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          child: ListTile(
            onTap: () => _toClipboard(res.command),
            leading: RichText(
              text: TextSpan(text: "$indexStr ",style: const TextStyle(color: Colors.black,fontSize: 16), children: [
                res.isSuccess
                    ? const TextSpan(
                        text: "成功\n", style: TextStyle(color: Colors.green))
                    : const TextSpan(
                        text: "失败\n", style: TextStyle(color: Colors.red))
              ]),
            ),
            title: Text(
                "$indexResStr : $resStr ${res.errorString != "" ? "失败原因（可能是警告，只要执行结果是成功就行）: ${res.errorString?.trim()}" : ""} [结果end]"),
            subtitle: Text("command : '${res.command}",style: const TextStyle(fontWeight: FontWeight.bold),),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    if (index == 0 || index == 1 || index == 6 || index == 7) {
      return InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        onTap: () => logic.menuLogic(index),
        child: Container(
          // padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Colors.lightGreen)),
          child: Center(child: Text(logic.menuString[index],textAlign: TextAlign.center,)),
        ),
      );
    } else {
      return _buildDeviceItem(index);
    }
  }

  Widget _buildDeviceItem(int index) {
    return Obx(() {
      return InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        onTap: state.currentDevice.value.isUnknown
            ? null
            : () => logic.menuLogic(index),
        child: Container(
          // padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(
                  color: state.currentDevice.value.isUnknown
                      ? Colors.black26
                      : Colors.lightBlue)),
          child: Center(child: Text(logic.menuString[index])),
        ),
      );
    });
  }

  List<Widget> _buildDeviceInfo() {
    if (state.devices.isNotEmpty) {
      return List.generate(
          state.devices.length,
          (index) => Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Obx(() {
                    return RadioListTile(
                        title: Text.rich(
                          TextSpan(
                            text: "",
                            children: [
                              const TextSpan(
                                  text: "设备名称: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: state.devices[index].name,
                                  style: const TextStyle(color: Colors.green)),
                              //model
                              state.devices[index].model != null
                                  ? TextSpan(
                                      text:
                                          "(${state.devices[index].model!.trim()})",
                                      style: const TextStyle(
                                          color: Colors.black87))
                                  : const TextSpan(text: ""),
                              //marketName
                              state.devices[index].marketName != null
                                  ? TextSpan(
                                      text:
                                          "(${state.devices[index].marketName!.trim()})",
                                      style: const TextStyle(
                                          color: Colors.black87))
                                  : const TextSpan(text: ""),
                              const TextSpan(
                                  text: " ,连接方式: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              state.devices[index].isWifiConnected
                                  ? TextSpan(
                                      text: state.devices[index].way,
                                      style:
                                          const TextStyle(color: Colors.orange))
                                  : TextSpan(
                                      text: state.devices[index].way,
                                      style: const TextStyle(
                                          color: Colors.purple)),
                            ],
                          ),
                        ),
                        value: index,
                        groupValue: state.selectedIndex.value,
                        onChanged: (v) {
                          state.selectedIndex.value = v ?? -1;
                          if (v == null) return;
                          state.currentDevice.value = state.devices[v];
                          print(
                              "current device : ${state.currentDevice.value}");
                        });
                  })
                ],
              ));
    } else {
      return [
        // RadioListTile(value: 0, groupValue: state.selectedIndex.value, onChanged: (v)=>state.selectedIndex.value = v ?? -1),
        // RadioListTile(value: 1, groupValue: state.selectedIndex.value, onChanged: (v)=>state.selectedIndex.value = v ?? -1),
      ];
    }
  }

  void _toClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    SmartDialog.showToast('复制命令成功！');
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;

  bool get isSuccess => state.currentResult.value.exitCode == 0;

  bool get isHaveResult =>
      state.currentResult.value.exitCode != CommandResult.defaultCode;

  static const logTitle = "日志信息";
  static const notice = "注：文件路径中不要包含空格";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // DrawableLayerWidget(drawableLayers: [Sky(), Sun()]),
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
                              child:
                                  // ListView.builder(
                                  //   itemCount: logic.menuString.length,
                                  //   itemBuilder: _buildMenuItem,
                                  // ),
                                  GridView.builder(
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
                // const Divider(),
                const Text(notice,
                    style: TextStyle(color: Colors.red, fontSize: 22)),
                Expanded(
                    flex: 2,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(20)),
                      child: Obx(() => isHaveResult
                          ? _buildResultInfo()
                          : const Center(child: Text(logTitle, style: TextStyle(fontSize: 22)))),
                    ))
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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("命令执行结果："),
              isSuccess
                  ? const Text("成功", style: TextStyle(color: Colors.green))
                  : const Text("失败", style: TextStyle(color: Colors.red))
            ]),
            Center(
                child: Text(
                    "结果 ： ${state.currentResult.value.outString} [结果end]")),
            state.currentResult.value.errorString != ""
                ? Center(
                    child: Text(
                        "失败原因（可能是警告，只要执行结果是成功就行）: ${state.currentResult.value.errorString}"))
                : const SizedBox()
          ],
        );
      }),
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
          child: Center(child: Text(logic.menuString[index])),
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
}

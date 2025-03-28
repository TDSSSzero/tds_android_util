import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/common/config.dart';
import 'package:tds_android_util/model/command_result.dart';
import 'package:tds_android_util/model/home_menu.dart';
import '../../common/font_styles.dart';
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
                  flex: 6,
                  child: _buildBody(),
                ),
                const Text("version : ${Config.version}"),
                const Text("author: tdsss")
              ],
            ),
          )
        ],
      ),
    );
  }

  Row _buildBody() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildInfo()),
        const VerticalDivider(),
        Expanded(flex: 2, child: _buildMenuArea()),
      ],
    );
  }

  Widget _buildMenuArea() {
    return Column(
      children: [
        Expanded(
          child: _buildMenu("普通菜单", state.normalMenu),
        ),
        const Divider(),
        Expanded(
          child: _buildMenu("需要连接设备菜单", state.needDeviceMenu),
        ),
      ],
    );
    // return Container(
    //     padding: const EdgeInsets.symmetric(horizontal: 30.0),
    //     child: GridView.builder(
    //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //           crossAxisCount: 3, crossAxisSpacing: 50, mainAxisSpacing: 15),
    //       itemBuilder: _buildMenuItem,
    //       itemCount: state.menu.length,
    //     ));
  }

  Widget _buildMenu(String menuTitle, List<HomeMenu> list) {
    final isNeedDevice = list[0].tagList?.contains(MenuTag.needDevice) ?? false;
    return Column(
      children: [
        Text(menuTitle, style: FontStyles.title),
        // const Divider(),
        Expanded(
          child: Material(
            //确保能被正常裁剪，此处必须加上Material
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  if (state.currentDevice.value.isUnknown && isNeedDevice) {
                    return _buildMenuItem(null, list, index);
                  }
                  return _buildMenuItem(list[index].func, list, index);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      Function()? menuFuc, List<HomeMenu> list, int index) {
    final menu = list[index];
    if(menu.tagList != null){
      if(state.currentDevice.value.isWifiConnected && menu.tagList!.contains(MenuTag.wifiDisable)) {
        menuFuc = null;
      }
    }

    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ListTile(
            enabled: menuFuc != null,
            onTap: menuFuc,
            title: Center(child: Text(menu.name)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
                side: BorderSide(color: Theme.of(context).dividerColor)),
          ),
        );
      }
    );
  }

  Column _buildInfo() {
    return Column(
      children: [
        Expanded(child: _buildDevices()),
        const Divider(),
        Expanded(child: _buildLogs()),
      ],
    );
  }

  Row _buildLogs() {
    return Row(
      children: [
        Expanded(
            child: Obx(() => isHaveResult
                ? _buildResultInfo()
                : const Align(
                    alignment: Alignment.topCenter,
                    child: Text(logTitle, style: FontStyles.title)))),
        const SizedBox(),
      ],
    );
  }

  Padding _buildDevices() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        return ListView(
          children: [
            const Text("设备列表",
                style: FontStyles.title, textAlign: TextAlign.center),
            ..._buildDeviceInfo()
          ],
        );
      }),
    );
  }

  Widget _buildResultInfo() {
    return Column(
      children: [
        const Text(logTitle, style: TextStyle(fontSize: 22)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            Expanded(
                flex: 3, child: Text('当前已执行${state.results.length}条命令,单击复制命令')),
            Expanded(
                child: IconButton(
                    onPressed: () {
                      state.currentResult.value = CommandResult.init();
                      state.results.clear();
                    },
                    icon: const Icon(Icons.cleaning_services_rounded),
                    color: Colors.grey)),
          ],
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Obx(() {
              return Column(
                children: [
                  _buildCommandRes(state.currentResult.value),
                  const Divider(),
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
          ),
        )
      ],
    );
  }

  Widget _buildCommandRes(CommandResult res, [int index = -1]) {
    String indexResStr = index == -1 ? "最后命令执行res" : "第${index + 1}条命令执行res ";
    String indexStr = index == -1 ? "最后命令 :" : "第${index + 1}条命令 : ";
    String resStr = res.outString.trim();
    if (resStr.length > 100) {
      resStr = resStr.substring(0, 100);
    }
    resStr += "...";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          child: ListTile(
            onTap: () => _toClipboard(res.command),
            leading: Builder(
              builder: (context) {
                return RichText(
                  text: TextSpan(
                      text: "$indexStr ",
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        res.isSuccess
                            ? TextSpan(
                                text: "成功\n", style: TextStyle(color: Theme.of(context).primaryColor))
                            : TextSpan(
                                text: "失败\n", style: TextStyle(color: Theme.of(context).colorScheme.error))
                      ]),
                );
              }
            ),
            title: Text(
              "command : ' ${res.command} '",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                "$indexResStr : $resStr ${res.errorString != "" ? "失败原因（可能是警告，只要执行结果是成功就行）: ${res.errorString?.trim()}" : ""} [end]"),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDeviceInfo() {
    if (state.devices.isNotEmpty) {
      return List.generate(
          state.devices.length, (index) => _buildDeviceInfoItem(index));
    } else {
      return [];
    }
  }

  Widget _buildDeviceInfoItem(int index) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Card(
              color: theme.colorScheme.surfaceContainer,
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                bool isWifi = state.currentDevice.value.isWifiConnected;
                return Hero(
                  tag: "device",
                  flightShuttleBuilder: (context, animation, direction, fromHero, toHero) {
                    if (direction == HeroFlightDirection.push) {
                      return toHero.widget; // 进入时正常显示
                    } else {
                      return const SizedBox.shrink(); // 返回时让 Hero 消失
                    }
                  },
                  child: RadioListTile(
                      secondary: Icon(isWifi
                          ? Icons.wifi
                          : Icons.phone_android,
                      color: theme.colorScheme.onSurface),
                      title: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                  text: "设备名称: ",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: state.devices[index].name,
                                  // style: TextStyle(color: theme.colorScheme.onSecondary)
                              ),
                              // const TextSpan(
                              //     text: " ,连接方式: ",
                              //     style: TextStyle(fontWeight: FontWeight.bold)),
                              // state.devices[index].isWifiConnected
                              //     ? TextSpan(
                              //         text: state.devices[index].way,
                              //         style: const TextStyle(color: Colors.orange))
                              //     : TextSpan(
                              //         text: state.devices[index].way,
                              //         style: const TextStyle(color: Colors.purple)),
                            ],
                          ),
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //brand
                          state.devices[index].brand != null
                              ? Text("(${state.devices[index].brand!.trim()})",
                                  style: const TextStyle(color: Colors.black87))
                              : const Text(""),
                          //model
                          state.devices[index].model != null
                              ? Text("(${state.devices[index].model!.trim()})",
                                  style: const TextStyle(color: Colors.black87))
                              : const Text(""),
                        ],
                      ),
                      value: index,
                      groupValue: state.selectedIndex.value,
                      onChanged: logic.onChangeSelectDevice),
                );
              }),
            )
          ],
        );
      }
    );
  }

  void _toClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    SmartDialog.showToast('复制命令成功！');
  }
}

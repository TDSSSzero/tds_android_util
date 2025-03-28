import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tds_android_util/common/font_styles.dart';
import 'package:tds_android_util/page/home/home_logic.dart';

import 'clear_app_logic.dart';

class ClearAppPage extends StatelessWidget {
  ClearAppPage({Key? key}) : super(key: key);

  final logic = Get.put(ClearAppLogic());
  final state = Get
      .find<ClearAppLogic>()
      .state;
  final homeLogic = Get.find<HomeLogic>();
  final homeState = Get
      .find<HomeLogic>()
      .state;

  static const spacing = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("清除数据"),
        backgroundColor: theme.cardColor,
        flexibleSpace: Center(
          child: Container(
            width: MediaQuery
                .sizeOf(context)
                .width * 0.5,
            alignment: Alignment.topCenter,
            child: _buildTitle(theme),
          ),
        ),
        // centerTitle: true
      ),
      body: Row(
        children: [
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    return DropdownMenu<int>(
                      dropdownMenuEntries: List.generate(
                          state.appList.length,
                              (index) =>
                              DropdownMenuEntry(
                                  value: index, label: state.appList[index]
                                  .alias)),
                      onSelected: logic.onSelectAppInfo,
                      width: 300,
                    );
                  }),
                  const SizedBox(height: spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("自定义包名："),
                      SizedBox(
                          width: 300,
                          child: TextField(
                            controller: logic.packageCtrl,
                            onChanged: logic.onCustomPackageInput,
                          )),
                    ],
                  )
                ],
              )),
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    return _buildSelectAppInfo();
                  }),
                  const SizedBox(height: spacing),
                  ElevatedButton(onPressed: logic.onClear, child: const Text("清除本地数据")),
                  const SizedBox(height: spacing),
                  ElevatedButton(onPressed: logic.packageCtrl.text.isNotEmpty ? logic.onClear : null, child: const Text("清除自定义包名本地数据")),
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildSelectAppInfo() {
    if (state.currentApp.value.package.isEmpty) return const SizedBox();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("当前appInfo:",style: FontStyles.info,),
        Text("别名: ${state.currentApp.value.alias}",style: FontStyles.info),
        Text("包名: ${state.currentApp.value.package}",style: FontStyles.info),
      ],
    );
  }

  Hero _buildTitle(ThemeData theme) {
    String brand = homeState.currentDevice.value.brand?.trim() ?? "";
    String model = homeState.currentDevice.value.model?.trim() ?? "";
    String name = homeState.currentDevice.value.name;
    return Hero(
      tag: "device",
      child: ListTile(
        trailing: Icon(
            homeState.currentDevice.value.isWifiConnected
                ? Icons.wifi
                : Icons.phone_android,
            color: theme.colorScheme.onSurface),
        title: Text(
            "设备名称: $name ${brand.isNotEmpty ? "($brand)" : ""}${model
                .isNotEmpty ? "($model)" : ""}"),
      ),
    );
  }

  // _onClear() {
  //   SmartDialog.show(builder: (_) =>
  //       DialogBase(
  //           width: 300,
  //           height: 200,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text("要删除")
  //             ],
  //           )
  //       )
  //   );
  // }
}

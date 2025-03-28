import 'package:shared_preferences/shared_preferences.dart';

/// author TDSSS
/// datetime 2025/3/27
final class SpManager {
  // 私有静态实例
  static final SpManager _instance = SpManager._internal();

  // 工厂构造函数返回单例实例
  factory SpManager() => _instance;

  // 私有构造函数
  SpManager._internal();

  // SharedPreferences 实例
  late final SharedPreferences sp;
  bool _isInit = false;

  // 初始化方法（异步）
  Future<void> init() async {
    if(_isInit)return;
    sp = await SharedPreferences.getInstance();
    _isInit = true;
  }
}
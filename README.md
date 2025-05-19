# TDS Android Util

<p align="center">
  <img src="./doc/screen.home_page.png" width="600">
</p>

## 📱 项目简介

TDS Android Util 是一款使用 Flutter 开发的 Windows 桌面应用程序，旨在简化 Android 开发和测试过程中的常见操作。通过集成 adb、aapt 等工具，实现了无线连接手机、文件传输、APK/AAB 安装等功能，提高开发效率。

## ✨ 主要功能

### 设备连接管理
- **获取设备列表**：自动检测并显示通过 adb 连接的所有设备
- **手动无线连接**：当无线连接断开时，可以通过手动方式重新建立连接
- **无线连接设备**：首次无线连接设备时，需要通过 USB 连接，选中已连接的设备后点击无线连接按钮

### 文件管理
- **复制文件到手机**：轻松将电脑上的任意文件复制到手机的 sdcard/APK 目录下

### 应用安装
- **安装 APK**：直接安装电脑上的 APK 文件到已连接的手机
- **安装 AAB**：支持直接安装电脑上的 AAB 文件到手机，可选择性构建 APKS
- **预设签名信息**：提前配置签名信息，在安装 AAB 时可以选择预设的签名配置

## 📸 界面展示

<p align="center">
  <img src="./doc/screen.install_apk.png" width="300">
  <img src="./doc/screen.sign_info.png" width="300">
</p>
<p align="center">
  <img src="./doc/screen.install_aab.png" width="300">
</p>

## 🔧 环境要求

- Windows 操作系统
- Flutter SDK >= 3.4.0
- 已安装 Android SDK 平台工具（项目已内置）

## 📦 依赖项

主要依赖：
- flutter_smart_dialog: ^4.9.7+8
- get: ^4.6.6
- desktop_drop: ^0.4.4
- file_picker: ^8.0.5
- path_provider: ^2.1.3
- shared_preferences: ^2.2.3
- qr_flutter: ^4.1.0
- win32: 5.8.0

## 🚀 安装与使用

1. 克隆项目到本地：
   ```
   git clone https://github.com/TDSSSzero/tds_android_util.git
   ```

2. 进入项目目录并安装依赖：
   ```
   cd tds_android_util
   flutter pub get
   ```

3. 运行应用：
   ```
   flutter run -d windows
   ```

## 📝 使用提示

- **首次无线连接**：确保手机和电脑在同一网络环境下，且手机已通过 USB 连接到电脑
- **AAB 安装**：安装 AAB 文件前，请确保已正确配置签名信息
- **文件传输**：可以通过拖拽方式将文件添加到应用中进行传输

## 🔒 注意事项

- 使用无线连接功能时，请确保手机和电脑在同一局域网内
- 部分功能可能需要手机开启 USB 调试模式和允许 ADB 调试
- 安装应用时可能需要在手机上手动确认安装权限

## 📄 许可证

[MIT License](LICENSE)

## 👨‍💻 贡献

欢迎提交 Issue 或 Pull Request 来帮助改进这个项目！

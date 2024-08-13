/// author TDSSS
/// datetime 2024/8/13
extension StringEx on String {
  String get filename {
    return substring(0,lastIndexOf("."));
  }

  String get apkName {
    return "${substring(0,lastIndexOf(".apk"))}.apk";
  }

  String get apksName {
    return "${substring(0,lastIndexOf("."))}.apks";
  }
}
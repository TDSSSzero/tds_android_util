
import 'package:cross_file/cross_file.dart';

/// author TDSSS
extension FileNameEx on XFile{
  String get filename {
    return name.substring(0,name.lastIndexOf("."));
  }

  String get apksName {
    return "${name.substring(0,name.lastIndexOf("."))}.apks";
  }
}
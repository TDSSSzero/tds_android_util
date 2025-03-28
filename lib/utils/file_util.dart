import 'dart:io';

final class FileUtil{
  FileUtil._();

  static String defaultSaveDir = "";

  static Future<bool> copyTo(String sourceFilePath,String targetFilePath)async{
    File sourceFile = File(sourceFilePath);
    if(!sourceFile.existsSync()){
      return false;
    }
    File targetFile = File(targetFilePath);
    targetFile.createSync();
    final data = await sourceFile.readAsBytes();
    File copyFile = await targetFile.writeAsBytes(data);
    return copyFile.existsSync();
  }

  static Future<List<String>> getAllDrive() async{
    List<String> drives = [];
    try {
      // 在 Windows 上，通常可以通过遍历 A 到 Z 盘来检查是否存在
      for (var letter = 'A'; letter.codeUnitAt(0) <= 'Z'.codeUnitAt(0); letter = String.fromCharCode(letter.codeUnitAt(0) + 1)) {
        var drivePath = '$letter:';
        var directory = Directory(drivePath);
        if (await directory.exists()) {
          drives.add(drivePath);
        }
      }
    } catch (e) {
      print('Error getting Windows drives: $e');
    }
    return drives;
  }

  static initDefaultSaveDir() async{
    if(defaultSaveDir.isNotEmpty)return;
    final driveList = await getAllDrive();
    if(driveList.isNotEmpty){
      StringBuffer targetPath = StringBuffer(driveList[0]);
      targetPath.write("\\tds_util_download");
      targetPath.write("");
      // defaultSaveDir = driveList
    }
  }
}
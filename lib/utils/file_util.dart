import 'dart:io';

final class FileUtil{
  FileUtil._();

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
}
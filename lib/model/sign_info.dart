/// author TDSSS
class SignInfo {
  String filePath;
  String alias;
  String storePassword;
  String keyPassword;

  SignInfo(this.filePath, this.alias, this.storePassword, this.keyPassword);

  // toJson方法：将对象转换为JSON
  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'alias': alias,
    'storePassword': storePassword,
    'keyPassword': keyPassword,
  };

  // 工厂方法fromJson：从JSON创建对象
  factory SignInfo.fromJson(Map<String, dynamic> json) {
    return SignInfo(
      json['filePath'] as String,
      json['alias'] as String,
      json['storePassword'] as String,
      json['keyPassword'] as String,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignInfo &&
          runtimeType == other.runtimeType &&
          alias == other.alias &&
          storePassword == other.storePassword &&
          keyPassword == other.keyPassword;

  @override
  int get hashCode =>
      alias.hashCode ^ storePassword.hashCode ^ keyPassword.hashCode;

  @override
  String toString() {
    return 'SignInfo{  alias: $alias, storePassword: $storePassword, keyPassword: $keyPassword,\n filePath: $filePath}\n';
  }
}
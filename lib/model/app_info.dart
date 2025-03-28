/// author TDSSS
/// datetime 2025/3/22
class AppInfo {
  String alias;
  String package;
  String? launchActivity;
  AppInfo(this.alias,this.package,{this.launchActivity});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          package == other.package;

  @override
  int get hashCode => package.hashCode;

  // Convert AppInfo to a Map
  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'package': package,
      'launchActivity': launchActivity,
    };
  }

  // Create AppInfo from a Map
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      json['alias'] as String,
      json['package'] as String,
      launchActivity: json['launchActivity'] as String?,
    );
  }

  @override
  String toString() {
    return 'AppInfo{alias: $alias, package: $package, launchActivity: $launchActivity}';
  }
}
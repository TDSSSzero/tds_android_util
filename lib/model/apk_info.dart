/// author TDSSS
class ApkInfo {
  String? packageName;
  String? launchActivity;
  ApkInfo(this.packageName, this.launchActivity);

  @override
  String toString() {
    return 'ApkInfo{packageName: $packageName, launchActivity: $launchActivity}';
  }
}
/// author TDSSS
class AndroidDevice {
  String name;
  String? ip;
  String? model;
  String? marketName;
  String? brand;
  bool isSelected;
  bool isWifiConnected;

  AndroidDevice(this.name,{this.ip, this.isSelected = false,this.isWifiConnected = false,this.model,this.marketName});
  factory AndroidDevice.init(){
    return AndroidDevice("unknown");
  }

  String get way => isWifiConnected ? "Wifi" : "USB";
  bool get isUnknown => name == "unknown";

  @override
  String toString() {
    return 'AndroidDevice{name: $name, ip: $ip, model: $model,marketName: $marketName, isSelected: $isSelected, isWifiConnected: $isWifiConnected}';
  }
}
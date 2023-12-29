/// author TDSSS

void main() {
  String text = """  
    List of devices attached  
    89602616	device  
    192.168.0.225:5555	device  
    192.168.0.111:5555	device  
  """;

  RegExp regex = RegExp(r"(\d+)\sdevice\s|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+)\sdevice");
  var match = regex.allMatches(text);

  for (var res in match) {
    if (res.group(1) != null) {
      print("Serial number 1: ${res.group(1)}");
    }
    if (res.group(2) != null) {
      print("ip 2: ${res.group(2)}");
    }
  }
}
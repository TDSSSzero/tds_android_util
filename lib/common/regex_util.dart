/// author TDSSS
abstract class RegexUtil {
  static const ipRegex = r"((\d{1,3}\.){3}\d{1,3})";
  static const packageName = r"package: name='([^']+)'";
  static const launchActivity = r"launchable-activity: name='([^']+)'";

  static String? matchString(String? source,String pattern){
    if(source == null) return null;
    RegExp regExp = RegExp(pattern);
    var match = regExp.firstMatch(source);
    return match?.group(1);
  }

  static List<String> matchIp(String source){
    List<String> list = [];
    RegExp regExp = RegExp(ipRegex);
    Iterable<RegExpMatch> allMatch = regExp.allMatches(source);
    for (var res in allMatch) {
      final ip = res.group(1);
      if (ip != null) {
        print("ip : $ip");
        list.add(ip);
      }
    }
    return list;
  }
  static String? matchAdbIp(String source) {
    String? ip;
    RegExp ipRegex = RegExp(r"\bwlan0\b.*\bsrc\b ((\d{1,3}\.){3}\d{1,3})");
    var ipMatch = ipRegex.allMatches(source);
    for (var res in ipMatch) {
      ip = res.group(1);
    }
    return ip;
  }
}
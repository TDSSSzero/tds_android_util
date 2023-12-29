import 'dart:io';

/// author TDSSS
class CommandResult {
  static const defaultCode = -111;
  static const success = 0;
  static const error = 1;

  int exitCode = defaultCode;
  String command = "";
  String outString = "";
  String? errorString;

  CommandResult({required this.exitCode,required this.outString,this.errorString,required this.command});

  CommandResult.init();

  factory CommandResult.fromResult(ProcessResult result,String command){
    return CommandResult(
      exitCode: result.exitCode,
      outString: result.stdout,
      errorString: result.stderr,
      command: command
    );
  }

  bool get isSuccess => exitCode == success;

  @override
  String toString() {
    return 'CommandResult{command: $command, exitCode: $exitCode, outString: $outString, errorString: $errorString}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandResult &&
          runtimeType == other.runtimeType &&
          exitCode == other.exitCode &&
          outString == other.outString &&
          errorString == other.errorString;

  @override
  int get hashCode =>
      exitCode.hashCode ^ outString.hashCode ^ errorString.hashCode;
}

extension CommandResultIntCheck on int{
  bool isResultSuccess(int code) => code == 1;
}
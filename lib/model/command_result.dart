import 'dart:io';

/// author TDSSS

enum CommandResultCode{
  defaultCode(-111),
  success(0),
  error(1),
  ;
  final int code;
  const CommandResultCode(this.code);
}
class CommandResult {
  CommandResultCode exitCode = CommandResultCode.defaultCode;
  String command = "";
  String outString = "";
  String? errorString;

  CommandResult({required this.exitCode,required this.outString,this.errorString,required this.command});

  CommandResult.init();

  factory CommandResult.fromResult(ProcessResult result,String command){
    CommandResultCode code = CommandResultCode.defaultCode;
    switch(result.exitCode)
    {
      case 0:
        code = CommandResultCode.success;
      case 1:
        code = CommandResultCode.error;
    }
    return CommandResult(
      exitCode: code,
      outString: result.stdout,
      errorString: result.stderr,
      command: command
    );
  }

  bool get isSuccess => exitCode == CommandResultCode.success;

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
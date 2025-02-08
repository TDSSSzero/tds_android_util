// FILEPATH: tds_android_util/test/model/command_result_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:tds_android_util/model/command_result.dart';

void main() {
  group('CommandResultIntCheck', () {
    test('isResultSuccess should return true when code is 1', () {
      int code = 1;
      expect(code.isResultSuccess(code), isTrue);
    });

    test('isResultSuccess should return false when code is not 1', () {
      int code = 0;
      expect(code.isResultSuccess(code), isFalse);
    });
  });
}
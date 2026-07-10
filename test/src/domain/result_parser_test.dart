import 'package:fastest/src/domain/result_parser.dart';
import 'package:test/test.dart';

void main() {
  group('ResultParser', () {
    test('marca sucesso quando não há falhas e exitCode é 0', () {
      final parser = ResultParser(packageName: 'core')
        ..addStdout('00:01 +5: /app/test/foo_test.dart: passa');

      final result = parser.build(exitCode: 0);

      expect(result.success, isTrue);
      expect(result.failures, isEmpty);
      expect(result.packageName, equals('core'));
    });

    test('detecta falhas por arquivo a partir de linhas [E]', () {
      final parser = ResultParser(packageName: 'auth')
        ..addStdout(
          '00:02 +3 -1: /app/test/login_test.dart: senha [E] Expected: true',
        )
        ..addStdout(
          '00:02 +3 -2: /app/test/token_test.dart: expira [E] Expected: x',
        );

      final result = parser.build(exitCode: 1);

      expect(result.success, isFalse);
      expect(result.failures, hasLength(2));
      expect(
        result.failures.map((f) => f.file),
        containsAll(['login_test.dart', 'token_test.dart']),
      );
      expect(result.failures.first.description, equals('Expected: true'));
    });

    test('agrupa múltiplas falhas do mesmo arquivo em uma entrada', () {
      final parser = ResultParser(packageName: 'ui')
        ..addStdout('00:01 -1: /app/test/a_test.dart: caso 1 [E] erro')
        ..addStdout('00:02 -2: /app/test/a_test.dart: caso 2 [E] outro');

      final result = parser.build(exitCode: 1);

      expect(result.failures, hasLength(1));
      expect(result.failures.single.file, equals('a_test.dart'));
    });

    test('considera falha quando "Some tests failed" aparece', () {
      final parser = ResultParser(packageName: 'x')
        ..addStdout('Some tests failed.');

      expect(parser.build(exitCode: 1).success, isFalse);
    });

    test('ignora ruído de stderr do flutter', () {
      final parser = ResultParser(packageName: 'x')
        ..addStderr('Waiting for another flutter command to release the lock...')
        ..addStdout('00:01 +2: /app/test/ok_test.dart: passa');

      final result = parser.build(exitCode: 0);

      expect(result.success, isTrue);
      expect(result.errorLines, isEmpty);
    });
  });
}

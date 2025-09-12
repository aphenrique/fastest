import 'dart:io';

import 'package:fastest/src/runner/process_runner.dart';
import 'package:fastest/src/view/test_output.dart';
import 'package:test/test.dart';

class MockProcessRunner extends ProcessRunner {
  @override
  Future<int> execute() async {
    return 0;
  }
}

void main() {
  late MockProcessRunner processRunner;
  late TestOutput testOutput;

  setUp(() {
    processRunner = MockProcessRunner();
    testOutput = TestOutput(false, packageName: 'test', failFast: false);
  });

  group('ProcessRunner', () {
    test('startProcess deve iniciar um processo com os argumentos corretos',
        () async {
      final process = await processRunner.startProcess(
        'echo',
        ['test'],
        workingDirectory: '.',
      );

      expect(process, isA<Process>());
      expect(await process.exitCode, equals(0));
    });

    test('handleProcessOutput deve retornar o código de saída do processo',
        () async {
      final process = await processRunner.startProcess(
        'echo',
        ['test'],
        workingDirectory: '.',
      );

      final exitCode = await processRunner.handleProcessOutput(
        process,
        testOutput,
        false,
      );

      expect(exitCode, equals(0));
    });

    test(
        'handleProcessOutput deve encerrar o processo quando failFast é true e exitCode não é 0',
        () async {
      final process = await processRunner.startProcess(
        'false', // Comando que sempre retorna código de saída 1
        [],
        workingDirectory: '.',
      );

      expect(
        () => processRunner.handleProcessOutput(process, testOutput, true),
        throwsA(isA<StateError>()),
      );
    });
  });
}

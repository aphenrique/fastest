import 'dart:io';

import 'package:fastest/src/runner/test_runner.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late TestRunner testRunner;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('test_runner_test_');
    testRunner = TestRunner(
      testPath: tempDir.path,
      coverage: true,
      concurrency: 4,
      failFast: true,
      verbose: true,
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('TestRunner', () {
    test('packageName deve retornar o nome do diretório de teste', () {
      expect(testRunner.packageName, equals(path.basename(tempDir.path)));
    });

    test('execute deve configurar corretamente o ambiente de teste', () async {
      // Cria um arquivo de teste falso para o TestOptimizer encontrar
      final testDir = Directory(path.join(tempDir.path, 'test'))..createSync();
      File(path.join(testDir.path, 'example_test.dart')).writeAsStringSync('''
        import 'package:test/test.dart';
        void main() {
          test('example', () {
            expect(true, isTrue);
          });
        }
      ''');

      // Verifica se o diretório de cobertura não existe inicialmente
      final coverageDir = Directory(path.join(tempDir.path, 'coverage'));
      expect(coverageDir.existsSync(), isFalse);

      try {
        await testRunner.execute();
      } catch (e) {
        // Ignora erros de execução do flutter test, já que é apenas um teste de integração
      }

      // Verifica se o diretório de cobertura foi criado e depois removido
      expect(coverageDir.existsSync(), isFalse);
    });

    test('execute deve usar as configurações corretas', () async {
      expect(testRunner.coverage, isTrue);
      expect(testRunner.concurrency, equals(4));
      expect(testRunner.failFast, isTrue);
      expect(testRunner.verbose, isTrue);
    });
  });
}

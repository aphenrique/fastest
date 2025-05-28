import 'dart:io';

import 'package:path/path.dart' as path;

import 'test_file_generator.dart';
import 'test_finder.dart';

class TestRunner {
  final String projectPath;
  final bool coverage;

  TestRunner(this.projectPath, {this.coverage = false});

  Future<void> execute() async {
    final testFile = generateTestFile(projectPath);

    if (coverage) {
      final coverageDir = Directory(path.join(projectPath, 'coverage'));
      if (coverageDir.existsSync()) {
        print('\nRemovendo pasta coverage antiga...');
        coverageDir.deleteSync(recursive: true);
      }
    }

    print('\nExecutando os testes...\n');

    final testArgs = [
      'test',
      testFile,
      '--concurrency=4',
    ];

    if (coverage) {
      testArgs.add('--coverage');
    }

    final result = await Process.run(
      'flutter',
      testArgs,
      runInShell: true,
      workingDirectory: projectPath,
    );

    final failedTests = findFailedTests(result.stdout.toString());
    if (failedTests.isNotEmpty) {
      print('\nArquivos com falha:');
      for (final test in failedTests) {
        print('❌ $test');
      }
    } else {
      print('\n🏆 Todos os testes passaram com sucesso!');
    }

    exit(result.exitCode);
  }
}

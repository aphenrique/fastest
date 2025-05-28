import 'dart:io';

import 'test_file_generator.dart';
import 'test_finder.dart';

class TestRunner {
  final String projectPath;

  TestRunner(this.projectPath);

  Future<void> execute() async {
    final testFile = generateTestFile(projectPath);

    print('\nExecutando os testes...\n');

    final result = await Process.run(
      'flutter',
      [
        'test',
        testFile,
        '--concurrency=4',
      ],
      runInShell: true,
      workingDirectory: projectPath,
    );

    final failedTests = findFailedTests(result.stdout.toString());
    if (failedTests.isNotEmpty) {
      print('\nArquivos com falha:');
      for (final test in failedTests) {
        print('❌ $test');
      }
    }

    

    exit(result.exitCode);
  }
}

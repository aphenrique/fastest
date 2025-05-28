import 'dart:io';

import 'package:path/path.dart' as path;

import 'test_file_generator.dart';
import 'test_finder.dart';

class TestRunner {
  final String projectPath;
  final bool coverage;
  final int concurrency;

  TestRunner(
    this.projectPath, {
    this.coverage = false,
    this.concurrency = 4,
  });

  Future<void> execute() async {
    final stopwatch = Stopwatch()..start();

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
      '--concurrency=$concurrency',
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
    final totalTests = _getTotalTests(result.stdout.toString());

    if (failedTests.isNotEmpty) {
      print('\nArquivos com falha:');
      for (final test in failedTests) {
        print('❌ $test');
      }
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;

    print('\nResumo da execução:');
    print('Total de testes: $totalTests');
    print('Testes com falha: ${failedTests.length}');
    print('Testes com sucesso: ${totalTests - failedTests.length}');
    print('Tempo total: ${_formatDuration(minutes, seconds, milliseconds)}');

    exit(result.exitCode);
  }

  int _getTotalTests(String output) {
    // Procura por uma linha como "00:07 +397 -1: Some tests failed."
    final resultLine = output.split('\n').firstWhere(
          (line) =>
              line.contains('+') && line.contains('-') && line.contains(':'),
          orElse: () => '',
        );

    if (resultLine.isEmpty) return 0;

    // Extrai os números após os símbolos + e -
    final passed = int.tryParse(resultLine.split('+')[1].split(' ')[0]) ?? 0;

    final failed = int.tryParse(resultLine.split('-')[1].split(':')[0]) ?? 0;

    return passed + failed;
  }

  String _formatDuration(int minutes, int seconds, int milliseconds) {
    final parts = <String>[];

    if (minutes > 0) {
      parts.add('${minutes}m');
    }
    if (seconds > 0 || minutes > 0) {
      parts.add('${seconds}s');
    }
    parts.add('${milliseconds}ms');

    return parts.join(' ');
  }
}

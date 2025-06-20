import 'dart:async';

import 'monorepo_runner.dart';
import 'test_runner.dart';

abstract class Runner {
  factory Runner({
    required bool isPackage,
    required String testPath,
    required bool coverage,
    required int concurrency,
    required bool failFast,
    required bool verbose,
  }) {
    switch (isPackage) {
      case true:
        return MonorepoRunner(
          rootPath: testPath,
          coverage: coverage,
          concurrency: concurrency,
          failFast: failFast,
          verbose: verbose,
        );
      case false:
        return TestRunner(
          coverage: coverage,
          concurrency: concurrency,
          testPath: testPath,
          failFast: failFast,
          verbose: verbose,
        );
      default:
        throw Exception('Falha ao criar o runner');
    }
  }

  Future<int> execute();
}

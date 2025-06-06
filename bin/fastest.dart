import 'dart:io';

import 'package:fastest/src/test_optimizer.dart';
import 'package:fastest/src/test_runner.dart';

void main(List<String> args) async {
  final coverage = args.contains('--coverage');
  final concurrency =
      args.contains('--concurrency') ? Platform.numberOfProcessors : 1;

  final optimizer = TestOptimizer();

  final runner = TestRunner(
    optimizer,
    coverage: coverage,
    concurrency: concurrency,
  );

  await runner.execute();
}

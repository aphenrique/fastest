import 'dart:io';

import 'package:speed_test/speed_test.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Por favor, forneça o caminho do projeto como argumento.');
    exit(1);
  }

  final projectPath = args[0];
  final coverage = args.contains('--coverage');
  final runner = TestRunner(projectPath, coverage: coverage);
  await runner.execute();
}

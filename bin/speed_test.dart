import 'dart:io';

import 'package:speed_test/src/test_runner.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Por favor, forneça o caminho do projeto como argumento.');
    exit(1);
  }

  final projectPath = args[0];
  final runner = TestRunner(projectPath);
  await runner.execute();
}

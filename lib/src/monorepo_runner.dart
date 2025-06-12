import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

import 'colored_output.dart';
import 'console_color.dart';
import 'test_optimizer.dart';
import 'test_runner.dart';

class MonorepoRunner {
  MonorepoRunner({
    required this.rootPath,
    required this.coverage,
    required this.concurrency,
  });

  final String rootPath;
  final bool coverage;
  final int concurrency;

  Future<void> execute() async {
    final rootDir = Directory(rootPath);
    if (!rootDir.existsSync()) {
      throw Exception('Diretório raiz não encontrado: $rootPath');
    }

    final packages = await _findDartPackages(rootDir);
    if (packages.isEmpty) {
      throw Exception('Nenhum pacote Dart/Flutter encontrado em: $rootPath');
    }

    ColoredOutput.writeln(
      ConsoleColor.cyan,
      'Encontrados ${packages.length} pacotes:',
    );

    var hasFailures = false;
    final executeList = <Future<void>>[];

    for (final package in packages) {
      ColoredOutput.writeln(
        ConsoleColor.yellow,
        '\nExecutando testes em: ${package.path}',
      );

      try {
        final runner = TestRunner(
          TestOptimizer(),
          coverage: coverage,
          concurrency: concurrency,
          testPath: package.path,
        );

        executeList.add(
          Isolate.run(runner.execute),
        );
        // await runner.execute();
      } catch (e) {
        hasFailures = true;
        ColoredOutput.writeln(
          ConsoleColor.red,
          'Falha ao executar testes em: ${package.path}',
        );
      }
    }

    await Future.wait(executeList);

    if (hasFailures) {
      exit(1);
    } else {
      exit(0);
    }
  }

  Future<List<Directory>> _findDartPackages(Directory root) async {
    final packages = <Directory>[];

    for (final entity in root.listSync()) {
      if (entity is Directory) {
        final pubspecFile = File(path.join(entity.path, 'pubspec.yaml'));
        final testDir = Directory(path.join(entity.path, 'test'));

        if (pubspecFile.existsSync() && testDir.existsSync()) {
          // Verifica se há arquivos de teste na pasta
          final testFiles = testDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('_test.dart'))
              .toList();

          if (testFiles.isNotEmpty) {
            packages.add(entity);
          }
        }
      }
    }

    return packages;
  }
}

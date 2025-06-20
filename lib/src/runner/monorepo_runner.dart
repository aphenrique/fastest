import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

import '../output/colored_output.dart';
import '../output/console_color.dart';
import 'runner.dart';
import 'test_runner.dart';

class MonorepoRunner implements Runner {
  MonorepoRunner({
    required this.rootPath,
    required this.coverage,
    required this.concurrency,
    this.failFast = false,
    this.verbose = false,
  });

  final String rootPath;
  final bool coverage;
  final int concurrency;
  final bool failFast;
  final bool verbose;
  
  @override
  Future<int> execute() async {
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
      'Encontrados ${packages.length} pacotes:\n',
    );

    var hasFailures = false;
    final queue = packages.toList();
    final running = <Future<int>>[];

    // Iniciar o loading animation
    var isRunning = true;
    final loadingChars = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    var loadingIndex = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isRunning) {
        timer.cancel();
        return;
      }

      stdout.write('\r${loadingChars[loadingIndex]} Executando testes...');
      loadingIndex = (loadingIndex + 1) % loadingChars.length;
    });

    while (queue.isNotEmpty || running.isNotEmpty) {
      // Preenche o pool até o máximo permitido pelo concurrency
      while (queue.isNotEmpty && running.length < concurrency) {
        final package = queue.removeAt(0);

        try {
          final runner = TestRunner(
            coverage: coverage,
            concurrency: concurrency,
            testPath: package.path,
            failFast: failFast,
          );

          final future = Isolate.run(runner.execute).catchError((error) {
            hasFailures = true;
            ColoredOutput.writeln(
              ConsoleColor.red,
              'Falha ao executar testes em: ${package.path}',
            );
            return 2;
          });

          running.add(future);
        } catch (e) {
          hasFailures = true;
          ColoredOutput.writeln(
            ConsoleColor.red,
            'Falha ao executar testes em: ${package.path}',
          );
        }
      }

      // Espera pelo menos um dos testes completar antes de continuar
      if (running.isNotEmpty) {
        final results = await Future.wait([running.removeAt(0)]);
        if (failFast && results.any((code) => code != 0)) {
          isRunning = false;
          return 1;
        }
      }
    }

    isRunning = false;

    if (hasFailures) {
      return 1;
    } else {
      return 0;
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

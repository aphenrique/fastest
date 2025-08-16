import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

import '../view/colored_output.dart';
import '../view/console_color.dart';
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

    final queue = await _findDartPackages(rootDir);
    if (queue.isEmpty) {
      throw Exception('Nenhum pacote Dart/Flutter encontrado em: $rootPath');
    }

    ColoredOutput.writeln(
      ConsoleColor.cyan,
      'Encontrados ${queue.length} pacotes:\n',
    );

    var hasFailures = false;

    final running = Queue<Future<int>>();

    // Iniciar o loading animation
    var isRunning = true;
    final loadingChars = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    var loadingIndex = 0;

    // TODO(Henrique): Remover para standart output
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isRunning) {
        timer.cancel();
        return;
      }

      // stdout.write('\r${loadingChars[loadingIndex]} Executando testes...');
      loadingIndex = (loadingIndex + 1) % loadingChars.length;
    });

    while (queue.isNotEmpty || running.isNotEmpty) {
      // Preenche o pool até o máximo permitido pelo concurrency
      while (queue.isNotEmpty && running.length < concurrency) {
        final package = queue.removeFirst();

        try {
          final runner = TestRunner(
            testPath: package.path,
            coverage: coverage,
            // concurrency: concurrency,
            failFast: failFast,
            verbose: verbose,
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
        final results = await Future.wait([running.removeFirst()]);
        if (failFast && results.any((code) => code != 0)) {
          return 9;
        }
      }

      isRunning = false;
    }

    return hasFailures ? 1 : 0;
  }

  Future<Queue<Directory>> _findDartPackages(Directory root) async {
    final packages = Queue<Directory>();

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
